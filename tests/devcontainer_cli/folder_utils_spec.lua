local folder_utils = require("devcontainer_cli.folder_utils")

describe("In folder_utils functions", function()
  it(
    "checks if M.folder_exists function has the root folder as a reference even when we are in another folder",
    function()
      -- dbg()
      -- This test assumes that we are in the root folder of the project
      local project_root_folder = vim.fn.getcwd()
      -- We change the current directory to a subfolder
      vim.fn.chdir("lua/devcontainer_cli")
      local devcontainer_cli_folder = vim.fn.getcwd()
      -- First we check that the we properly changed the directory
      assert(devcontainer_cli_folder == project_root_folder .. "/lua/devcontainer_cli")
      -- In such subfolder the function for getting the git_root_folder is called
      local git_root_folder = folder_utils.get_git_root_folder()
      -- From the subfolder, we check that the get_git_root_folder function returns the folder where the git repo is located instead of the CWD
      assert(git_root_folder == project_root_folder)
      -- Finally the the folder_exists function is tested to check that it always checks if the folder exists in the root folder even when we are in another folder
      assert(folder_utils.folder_exists(".devcontainer/"))
      -- After running the test we come back to the initial location
      vim.fn.chdir(project_root_folder)
    end
  )
end)
