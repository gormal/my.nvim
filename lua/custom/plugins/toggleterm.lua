return {
  -- Horizontal terminal
  {
    'akinsho/toggleterm.nvim',
    opts = {}, -- You can add any additional options here if needed
    keys = function(_, _)
      local Terminal = require('toggleterm.terminal').Terminal

      -- Persistent terminal instances for each direction
      local horizontal_term = Terminal:new { direction = 'horizontal' }
      local vertical_term = Terminal:new { direction = 'vertical' }
      local float_term = Terminal:new { direction = 'float' }

      -- Key mappings to toggle each terminal
      vim.keymap.set('n', '<leader>th', function()
        horizontal_term:toggle()
      end, { noremap = true, silent = true, desc = '[H]orrizontally split terminal' })
      vim.keymap.set('n', '<leader>tv', function()
        vertical_term:toggle()
      end, { noremap = true, silent = true, desc = '[V]ertically split terminal' })
      vim.keymap.set('n', '<leader>tf', function()
        float_term:toggle()
      end, { noremap = true, silent = true, desc = '[F]loating terminal' })

      -- Map <ESC><ESC> in terminal mode to close the terminal
      function _G.close_term_on_double_esc()
        local term_id = vim.b.toggle_number
        if term_id then
          require('toggleterm.terminal').get(term_id):toggle()
        end
      end

      vim.keymap.set('t', '<esc><esc>', '<C-\\><C-n>:lua close_term_on_double_esc()<CR>', { noremap = true, silent = true })
    end,
    config = function() end,
  },
}
