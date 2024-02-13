local M = {}

-- TODO: implement timeline
local timeline = function()
  print("Nostr timeline")
end

local post = function(text)
  vim.fn.system({ "algia", "post", text })
end

function M.setup()
  vim.api.nvim_create_user_command("Nostr", function()
    timeline()
  end, {})

  vim.api.nvim_create_user_command("NostrPost", function(opts)
    post(opts.args)
  end, { nargs = "+" })
end

return M
