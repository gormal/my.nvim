-- debug.lua
--
-- Shows how to use the DAP plugin to debug your code.
--
-- Primarily focused on configuring the debugger for Go, but can
-- be extended to other languages as well. That's why it's called
-- kickstart.nvim and not kitchen-sink.nvim ;)

return {
  -- NOTE: Yes, you can install new plugins here!
  'mfussenegger/nvim-dap',
  -- NOTE: And you can specify dependencies as well
  dependencies = {
    -- Creates a beautiful debugger UI
    'rcarriga/nvim-dap-ui',

    -- Required dependency for nvim-dap-ui
    'nvim-neotest/nvim-nio',

    -- Installs the debug adapters for you
    'williamboman/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',

    -- Add your own debuggers here
    'leoluz/nvim-dap-go',
  },
  keys = function(_, keys)
    local dap = require 'dap'
    local dapui = require 'dapui'
    return {
      -- Basic debugging keymaps, feel free to change to your liking!
      { '<F5>', dap.continue, desc = 'Debug: Start/Continue' },
      { '<F11>', dap.step_into, desc = 'Debug: Step Into' },
      { '<F10>', dap.step_over, desc = 'Debug: Step Over' },
      { '<F12>', dap.step_out, desc = 'Debug: Step Out' },
      { '<leader>b', dap.toggle_breakpoint, desc = 'Debug: Toggle Breakpoint' },
      {
        '<leader>B',
        function()
          dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
        end,
        desc = 'Debug: Set Breakpoint',
      },
      -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
      { '<F7>', dapui.toggle, desc = 'Debug: See last session result.' },
      unpack(keys),
    }
  end,
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    require('mason-nvim-dap').setup {
      -- Makes a best effort to setup the various debuggers with
      -- reasonable debug configurations
      automatic_installation = true,

      -- You can provide additional configuration to the handlers,
      -- see mason-nvim-dap README for more information
      handlers = {},

      -- You'll need to check that you have the required things installed
      -- online, please don't ask me how to install them :)
      ensure_installed = {
        -- Update this to ensure that you have the debuggers for the langs you want
        'delve',
        'coreclr',
      },
    }
    vim.keymap.set('n', '<space>?', function()
      require('dapui').eval(nil, { enter = true })
    end)
    -- Dap UI setup
    -- For more information, see |:help nvim-dap-ui|
    dapui.setup {}

    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close
    vim.fn.sign_define('DapBreakpoint', { text = '', texthl = 'Error', linhl = '', numhl = '' })
    vim.fn.sign_define('DapStopped', { text = '▶', texthl = 'Error', linehl = 'Visual', numhl = 'DapStopped' })
    require('dap-go').setup {
      delve = {
        -- On Windows delve must be run attached or it crashes.
        -- See https://github.com/leoluz/nvim-dap-go/blob/main/README.md#configuring
        detached = vim.fn.has 'win32' == 0,
      },
    }

    local function get_dll()
      return coroutine.create(function(dap_run_co)
        local items = vim.fn.globpath(vim.fn.getcwd(), '**/bin/Debug/**/*.dll', 0, 1)
        local opts = {
          format_item = function(path)
            return vim.fn.fnamemodify(path, ':t')
          end,
        }
        local function cont(choice)
          if choice == nil then
            return nil
          else
            coroutine.resume(dap_run_co, choice)
          end
        end

        vim.ui.select(items, opts, cont)
      end)
    end

    dap.configurations.cs = {
      {
        type = 'coreclr',
        name = 'Launch - NetCoreDbg - with args',
        request = 'launch',
        program = get_dll,
        args = function()
          local input = vim.fn.input('Command-line arguments: ', '')

          -- Use a more robust approach to split the arguments while respecting quoted strings
          local args = {}
          local in_quote = false
          local current_arg = ''

          for i = 1, #input do
            local char = input:sub(i, i)
            if char == '"' then
              in_quote = not in_quote -- Toggle quote state
            elseif char == ' ' and not in_quote then
              if current_arg ~= '' then
                table.insert(args, current_arg)
                current_arg = ''
              end
            else
              current_arg = current_arg .. char
            end
          end

          -- Add the last argument
          if current_arg ~= '' then
            table.insert(args, current_arg)
          end

          return args
        end,
        cwd = '${workspaceFolder}', -- Set current working directory
        stopAtEntry = false,
      },
      {
        type = 'coreclr',
        name = 'Launch - NetCoreDbg',
        request = 'launch',
        cwd = '${workspaceFolder}', -- Set current working directory
        stopAtEntry = false,
      },
    }
  end,
}
