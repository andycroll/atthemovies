has_app_changes = !git.modified_files.grep(/app/).empty?
has_test_changes = !git.modified_files.grep(/spec/).empty?

# PR is WIP
warn('PR is classed as Work in Progress') if github.pr_title.include? "[WIP]"

# Changes without tests?
if has_app_changes && !has_test_changes
  warn("There're library changes, but not tests. That's OK as long as you're refactoring existing code.", sticky: false)
end

# No merges
if git.commits.any? { |c| c.message =~ /^Merge branch '#{github.branch_for_base}'/ }
  fail('Please rebase to get rid of the merge commits in this PR')
end

# Rubocop for new files in /app or /lib
if has_app_changes || has_test_changes
  public_files = (git.modified_files + git.added_files).select do |path|
    path.include?('/app/') || path.include?('/spec/')
  end

  rubocop.lint public_files unless public_files.empty?
end
