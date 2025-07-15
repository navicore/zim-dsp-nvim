local Job = require("plenary.job")

return function()
	local cargo = vim.fn.executable("cargo") == 1 and "cargo" or nil
	if not cargo then
		vim.notify("[zim-dsp] Rust toolchain not found", vim.log.levels.ERROR)
		return
	end

	-- Get the plugin root directory
	local info = debug.getinfo(1, "S")
	local plugin_root = info.source:sub(2):match("(.*/)")
	
	-- Find the zim-dsp source repository
	local zim_dsp_repo = vim.fn.expand("~/git/navicore/zim-dsp")
	if vim.fn.isdirectory(zim_dsp_repo) == 0 then
		vim.notify("[zim-dsp] Source repository not found at: " .. zim_dsp_repo, vim.log.levels.ERROR)
		return
	end

	-- Build in the source directory
	local target_bin = zim_dsp_repo .. "/target/release/zim-dsp"
	local output_dir = vim.fn.stdpath("data") .. "/zim-dsp-bin"
	local output_path = output_dir .. "/zim-dsp"

	vim.fn.mkdir(output_dir, "p")

	Job:new({
		command = "cargo",
		args = { "build", "--release" },
		cwd = zim_dsp_repo,
		on_exit = function(j, return_val)
			if return_val == 0 and vim.fn.filereadable(target_bin) == 1 then
				vim.fn.system({ "cp", target_bin, output_path })
				vim.fn.system({ "chmod", "+x", output_path })
				print("[zim-dsp] Engine built and copied to: " .. output_path)
			else
				vim.notify("[zim-dsp] Cargo build failed.", vim.log.levels.ERROR)
			end
		end,
	}):start()
end