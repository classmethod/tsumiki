#!/usr/bin/env node

import { Command } from "commander";
import { gitignoreCommand } from "./commands/gitignore.js";
import { installCommand } from "./commands/install.js";
import { uninstallCommand } from "./commands/uninstall.js";

const program = new Command();

program
  .name("tsumiki")
  .description(
    "CLI tool for installing Tsumiki commands for various Coder environments",
  )
  .version("1.0.0");

program
  .command("install")
  .description(
    "Install Tsumiki command templates to the specified Coder environment",
  )
  .option("-t, --target <coder>", "Target Coder environment (claude or qwen)")
  .action((options) => installCommand(options.target));

program
  .command("uninstall")
  .description(
    "Uninstall Tsumiki command templates from the specified Coder environment",
  )
  .option("-t, --target <coder>", "Target Coder environment (claude or qwen)")
  .action((options) => uninstallCommand(options.target));

program
  .command("gitignore")
  .description("Add commands/*.{md,sh} to .gitignore file")
  .action(gitignoreCommand);

program.parse();
