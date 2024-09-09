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
      vim.keymap.set('n', '<leader>td', function()
        horizontal_term:toggle(5)
      end, { noremap = true, silent = true, desc = 'Toggle terminal [D]own' })
      vim.keymap.set('n', '<leader>tr', function()
        vertical_term:toggle(80)
      end, { noremap = true, silent = true, desc = 'Toggle terminal [Right]' })
      vim.keymap.set('n', '<leader>tf', function()
        float_term:toggle()
      end, { noremap = true, silent = true, desc = '[F]loating terminal' })
    end,
    config = function() end,
  },
}
