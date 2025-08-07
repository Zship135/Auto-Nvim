return {
  {
    "scottmckendry/cyberdream.nvim",
    priority = 1000,
    lazy = false,
    config = function()
      require("cyberdream").setup({
        transparent = false,
        italic_comments = true,
        hide_fillchars = true,
        custom_highlights = {
          Normal       = { fg = "#c5c9dc", bg = "#0f0f1a" },
          NormalNC     = { fg = "#a6accd", bg = "#0f0f1a" },
          Visual       = { bg = "#3b3052" },       -- cyberdream-styled purple
          Search       = { bg = "#354265", fg = "#ffffff", bold = true }, -- subtle blue highlight
          IncSearch    = { bg = "#7a90c4", fg = "#1a1b26", bold = true },
          LineNr       = { fg = "#4b4f68", bg = "#0f0f1a" },
          CursorLineNr = { fg = "#e2e5f0", bg = "#1e1f2e", bold = true },
          StatusLine   = { fg = "#c5c9dc", bg = "#1a1b26" },
          FloatBorder  = { fg = "#7a90c4", bg = "#1a1b26" },
          Pmenu        = { fg = "#e2e5f0", bg = "#1e1f2e" },
          PmenuSel     = { fg = "#1a1b26", bg = "#9ccfd8", bold = true },
          Comment      = { fg = "#6e738d", italic = true },
          Keyword      = { fg = "#a277ff", italic = true },
          Identifier   = { fg = "#c5c9dc" },
          Function     = { fg = "#9ccfd8", bold = true },
          Type         = { fg = "#f694ff" },
          Constant     = { fg = "#ffaa88" },
        },
      })
      vim.cmd("colorscheme cyberdream")
    end,
  },
}

