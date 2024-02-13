local M = {}

function M.setup()
	vim.api.nvim_create_user_command("Nostr", function()
		print("Hello, Nostr!")
	end, {})
end

return M
