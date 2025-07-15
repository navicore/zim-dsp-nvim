-- Build script for zim-dsp-nvim
-- This builds the zim-dsp binary from source and installs it in the neovim data directory

return function()
	local cargo = vim.fn.executable("cargo") == 1 and "cargo" or nil
	if not cargo then
		vim.notify("[zim-dsp] Rust toolchain not found. Please install Rust.", vim.log.levels.ERROR)
		return
	end

	-- Find the zim-dsp source repository
	local zim_dsp_repo = vim.fn.expand("~/git/navicore/zim-dsp")
	if vim.fn.isdirectory(zim_dsp_repo) == 0 then
		vim.notify("[zim-dsp] Source repository not found at: " .. zim_dsp_repo, vim.log.levels.ERROR)
		vim.notify("[zim-dsp] Please clone https://github.com/navicore/zim-dsp to ~/git/navicore/zim-dsp", vim.log.levels.ERROR)
		return
	end

	local output_dir = vim.fn.stdpath("data") .. "/zim-dsp-bin"
	local output_path = output_dir .. "/zim-dsp"

	vim.fn.mkdir(output_dir, "p")

	-- Build zim-dsp
	vim.notify("[zim-dsp] Building from source at: " .. zim_dsp_repo, vim.log.levels.INFO)
	
	local Job = require("plenary.job")
	Job:new({
		command = "cargo",
		args = { "build", "--release" },
		cwd = zim_dsp_repo,
		on_exit = function(j, return_val)
			if return_val == 0 then
				local target_bin = zim_dsp_repo .. "/target/release/zim-dsp"
				if vim.fn.filereadable(target_bin) == 1 then
					vim.fn.system({ "cp", target_bin, output_path })
					vim.fn.system({ "chmod", "+x", output_path })
					vim.notify("[zim-dsp] Successfully built and installed to: " .. output_path, vim.log.levels.INFO)
				else
					vim.notify("[zim-dsp] Build succeeded but binary not found", vim.log.levels.ERROR)
				end
			else
				vim.notify("[zim-dsp] Build failed. Check Rust installation and try again.", vim.log.levels.ERROR)
			end
		end,
		on_stderr = function(_, data)
			for _, line in ipairs(data) do
				if line ~= "" and not line:match("^%s*Compiling") and not line:match("^%s*Finished") then
					print("[zim-dsp build] " .. line)
				end
			end
		end,
	}):start()
end