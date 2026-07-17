(local blocked-node-types {:fenced_code_block true
                           :indented_code_block true
                           :code_fence_content true
                           :pipe_table true
                           :pipe_table_header true
                           :pipe_table_row true
                           :pipe_table_cell true
                           :minus_metadata true
                           :plus_metadata true})

(fn whitespace? [char]
  (not= (string.match char "%s") nil))

(fn consume-spaces [line start]
  (var i start)
  (while (and (<= i (length line)) (whitespace? (line:sub i i)))
    (set i (+ i 1)))
  i)

(fn consume-container-prefix [line start]
  (var i (consume-spaces line start))
  (var did-consume true)
  (while did-consume
    (set did-consume false)
    (when (= (line:sub i i) ">")
      (set i (+ i 1))
      (when (= (line:sub i i) " ")
        (set i (+ i 1)))
      (set i (consume-spaces line i))
      (set did-consume true)))
  i)

(fn consume-list-marker [line start]
  (var i start)
  (let [rest (line:sub i)
        marker (or (string.match rest "^[%-%+%*]%s+")
                   (string.match rest "^%d+[%.%)]%s+"))]
    (when marker
      (set i (+ i (length marker)))
      (let [task (string.match (line:sub i) "^%[[ xX]%]%s+")]
        (when task
          (set i (+ i (length task)))))))
  i)

(fn prose-prefix [line]
  (let [prefix-end (- (consume-list-marker line
                                           (consume-container-prefix line 1))
                      1)]
    (line:sub 1 prefix-end)))

(fn continuation-prefix [prefix]
  (string.gsub prefix "[^>]" " "))

(fn line-content [line]
  (let [prefix (prose-prefix line)]
    (vim.trim (line:sub (+ (length prefix) 1)))))

(fn flatten-lines [lines]
  (let [parts []]
    (each [_ line (ipairs lines)]
      (let [content (line-content line)]
        (when (> (length content) 0)
          (table.insert parts content))))
    (vim.trim (table.concat parts " "))))

(fn find-closing [text delimiter start]
  (let [close-start (string.find text delimiter start true)]
    (when close-start
      (+ close-start (length delimiter) -1))))

(fn read-balanced-link [text start]
  (var label-start start)
  (when (= (text:sub start start) "!")
    (set label-start (+ start 1)))
  (when (= (text:sub label-start label-start) "[")
    (let [label-end (string.find text "]" (+ label-start 1) true)]
      (when (and label-end (= (text:sub (+ label-end 1) (+ label-end 1)) "("))
        (let [url-end (string.find text ")" (+ label-end 2) true)]
          url-end)))))

(fn read-angle-span [text start]
  (when (= (text:sub start start) "<")
    (let [opening-end (string.find text ">" (+ start 1) true)]
      (when opening-end
        (let [opening (text:sub start opening-end)
              tag-name (string.match opening "^<([%w:_%-]+)[^>]*>$")]
          (if tag-name
              (let [closing (.. "</" tag-name ">")
                    closing-start (string.find text closing (+ opening-end 1)
                                               true)]
                (if closing-start
                    (+ closing-start (length closing) -1)
                    opening-end))
              opening-end))))))

(fn read-token-end [text start]
  (let [char (text:sub start start)
        next2 (text:sub start (+ start 1))]
    (or (when (= char "`")
          (let [ticks (or (string.match (text:sub start) "^`+") "`")]
            (find-closing text ticks (+ start (length ticks)))))
        (when (or (= next2 "**") (= next2 "__") (= next2 "~~"))
          (find-closing text next2 (+ start 2)))
        (when (or (= char "*") (= char "_"))
          (find-closing text char (+ start 1)))
        (read-balanced-link text start) (read-angle-span text start))))

(fn tokenize [text]
  (let [tokens []]
    (var i 1)
    (while (<= i (length text))
      (if (whitespace? (text:sub i i))
          (set i (+ i 1))
          (let [span-end (read-token-end text i)]
            (if span-end
                (do
                  (table.insert tokens (text:sub i span-end))
                  (set i (+ span-end 1)))
                (do
                  (var j i)
                  (while (and (<= j (length text))
                              (not (whitespace? (text:sub j j))))
                    (set j (+ j 1)))
                  (table.insert tokens (text:sub i (- j 1)))
                  (set i j))))))
    tokens))

(fn display-width [text]
  (vim.fn.strdisplaywidth text))

(fn wrap-tokens [tokens first-prefix rest-prefix width]
  (let [lines []
        fallback-width 80
        target-width (if (> width 0) width fallback-width)]
    (var line "")
    (var line-prefix first-prefix)
    (var available (math.max 20 (- target-width (display-width line-prefix))))
    (each [_ token (ipairs tokens)]
      (let [candidate (if (= line "") token (.. line " " token))]
        (if (and (> (length line) 0) (> (display-width candidate) available))
            (do
              (table.insert lines (.. line-prefix line))
              (set line token)
              (set line-prefix rest-prefix)
              (set available
                   (math.max 20 (- target-width (display-width line-prefix)))))
            (set line candidate))))
    (when (> (length line) 0)
      (table.insert lines (.. line-prefix line)))
    lines))

(fn parser-root [buf]
  (let [result [(pcall vim.treesitter.get_parser buf :markdown)]
        ok (. result 1)
        parser (. result 2)]
    (when ok
      (let [trees (parser:parse)
            tree (. trees 1)]
        (when tree
          (tree:root))))))

(fn node-at-cursor [buf]
  (let [root (parser-root buf)]
    (when root
      (let [(row col) (unpack (vim.api.nvim_win_get_cursor 0))
            row (- row 1)]
        (root:named_descendant_for_range row col row col)))))

(fn target-paragraph [buf]
  (var node (node-at-cursor buf))
  (var target nil)
  (while (and node (not target))
    (let [node-type (node:type)]
      (if (. blocked-node-types node-type)
          (set node nil)
          (if (= node-type :paragraph)
              (set target node)
              (set node (node:parent))))))
  target)

(fn notify-no-target []
  (vim.notify "No markdown prose paragraph under cursor" vim.log.levels.INFO))

(fn paragraph-line-range [node]
  (let [(start-row _ end-row end-col) (node:range)] ; Tree-sitter ranges are end-exclusive. Column zero means the node ended on ; the previous line; otherwise include the line containing the endpoint.
    [start-row (if (= end-col 0) end-row (+ end-row 1))]))

(fn paragraph-lines [buf node]
  (let [[start-row end-row-exclusive] (paragraph-line-range node)]
    [(vim.api.nvim_buf_get_lines buf start-row end-row-exclusive false)
     start-row
     end-row-exclusive]))

(fn replace-paragraph [buf start-row end-row-exclusive new-lines]
  (vim.api.nvim_buf_set_lines buf start-row end-row-exclusive false new-lines))

(fn wrap-node [buf node]
  (let [[lines start-row end-row-exclusive] (paragraph-lines buf node)
        first-prefix (prose-prefix (. lines 1))
        rest-prefix (if (> (length lines) 1)
                        (prose-prefix (. lines 2))
                        (continuation-prefix first-prefix))
        text (flatten-lines lines)
        tokens (tokenize text)
        width vim.bo.textwidth
        wrapped (wrap-tokens tokens first-prefix rest-prefix width)]
    (when (> (length wrapped) 0)
      (replace-paragraph buf start-row end-row-exclusive wrapped))))

(fn unwrap-node [buf node]
  (let [[lines start-row end-row-exclusive] (paragraph-lines buf node)
        first-prefix (prose-prefix (. lines 1))
        text (flatten-lines lines)]
    (replace-paragraph buf start-row end-row-exclusive [(.. first-prefix text)])))

(fn with-target [callback]
  (let [buf (vim.api.nvim_get_current_buf)
        node (target-paragraph buf)]
    (if node
        (callback buf node)
        (notify-no-target))))

(fn wrap []
  (with-target wrap-node))

(fn unwrap []
  (with-target unwrap-node))

(fn toggle []
  (with-target (fn [buf node]
                 (let [[lines] (paragraph-lines buf node)]
                   (if (> (length lines) 1)
                       (unwrap-node buf node)
                       (wrap-node buf node))))))

{: wrap : unwrap : toggle}
