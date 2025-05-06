# Code Review Instructions

This file provides guidance for conducting effective code reviews in this repository.

## Review Focus Areas

- **Functionality**: Does the code work as intended and meet requirements?
- **Code Quality**: Is the code well-structured, maintainable, and readable?
- **Performance**: Are there any performance concerns or bottlenecks?
- **Security**: Are there any security vulnerabilities or risks?
- **Testing**: Is the code adequately tested?

## Language Consistency

- Ensure code follows project language conventions and idioms
- Verify consistent naming, formatting, and style
- Check that new code integrates well with existing patterns

## Specific Review Points

- **Neovim Configuration**:
  - Proper plugin organization in separate files
  - Appropriate use of Lua tables and config functions
  - Clear keymap documentation and sensible defaults
  - Efficient lazy-loading where appropriate

- **Shell Scripts**:
  - Error handling and appropriate exit codes
  - Proper variable quoting and safe practices
  - Clear documentation of dependencies and requirements

## Review Process

1. Understand the context and purpose of the changes
2. Review the code in detail, focusing on the areas above
3. Provide specific, actionable feedback
4. Distinguish between required changes and suggestions
5. Be constructive and respectful in all comments

## Review Comments

- Be specific and provide concrete examples
- Explain the reasoning behind suggestions
- Ask questions rather than making assumptions
- Acknowledge good solutions and creative approaches
- Focus on the code, not the author