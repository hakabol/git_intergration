local M = {}

function M.setup()
	vim.api.nvim_create_user_command("idk", function()
		print("idk")
	end, {})
end

return M
