-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    -- 'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  config = function()
    require('neo-tree').setup {
      event_handlers = {
        {
          event = 'file_opened',
          handler = function(file_path)
            -- Get a list of image file extensions
            local image_pattern = { 'png', 'jpg', 'jpeg', 'gif', 'bmp' }
            -- Get the extension and make it lowercase
            local ext = vim.fn.fnamemodify(file_path, ':e'):lower()
            local cmd = ''
            if vim.tbl_contains(image_pattern, ext) then
              -- os.execute('feh --g 1600x900 --scale-down ' .. file_path)
              -- Can make a more fancy version by using a list and then appending to list etc but eish, lots of efforts
              cmd = 'feh --g 1600x900 --scale-down ' .. file_path
            elseif ext == 'pdf' then
              cmd = 'zathura ' .. file_path
            else
              return
            end
            local bufnr = vim.api.nvim_get_current_buf()
            local dir_path = vim.fn.fnamemodify(file_path, ':h')
            -- print(cmd)
            -- os.execute(cmd)
            -- vim.cmd 'bp'
            vim.fn.jobstart(cmd, { detach = true })
            vim.cmd('bdelete ' .. tostring(bufnr))
            require('neo-tree.command').execute { action = 'focus' }
          end,
          desc = 'Open images with feh and PDFs with zathura and then return to the neo-tree window',
        },
      },
      close_last_window = true,
      -- vim.keymap.set('n', '\\', '<cmd>Neotree toggle<CR>', { silent = true, position = current, desc = 'Neotree: Toggle the neo tree file explorer.' }),
    }
  end,
  lazy = false,
  keys = {
    -- { '\\', ':Neotree toggle<CR>', desc = 'NeoTree toggle', silent = true },
    {
      '\\',
      function()
        require('neo-tree.command').execute { toggle = true, reveal = true, position = 'float' }
      end,
      desc = 'NeoTree toggle',
      silent = true,
    },
  },
  opts = {
    filesystem = {
      filtered_items = {
        visible = true,
      },
      components = {
        harpoon_index = function(config, node, _)
          local Marked = require 'harpoon.mark'
          local path = node:get_id()
          local success, index = pcall(Marked.get_index_of, path)
          if success and index and index > 0 then
            return {
              text = string.format('%d ', index), -- <-- Add your favorite harpoon like arrow here
              highlight = config.highlight or 'NeoTreeDirectoryIcon',
            }
          else
            return {
              text = '  ',
            }
          end
        end,
      },
      renderers = {
        file = {
          { 'icon' },
          { 'name', use_git_status_colors = true },
          { 'harpoon_index' }, --> This is what actually adds the component in where you want it
          { 'diagnostics' },
          { 'git_status', highlight = 'NeoTreeDimText' },
        },
      },
    },
  },
}
