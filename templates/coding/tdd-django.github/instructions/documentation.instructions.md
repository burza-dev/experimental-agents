---
applyTo: "**/docs/**/*.md,**/docs/**/*.rst,README.md,CONTRIBUTING.md"
---

# Documentation rules

## Writing style
- Clear and concise language
- Present tense for current behavior
- Active voice preferred over passive
- Technical accuracy is paramount

## Structure
- Use headings hierarchically (# → ## → ###)
- Include code examples for complex concepts
- Add cross-references where helpful
- Keep paragraphs short and focused

## Code examples
- All code examples must be correct and runnable
- Use syntax highlighting with language identifier
- Include expected output where relevant
- Test examples before committing

## README.md requirements
- Project description and purpose
- Installation instructions
- Quick start guide
- Link to full documentation
- License information

## API documentation
- Document all public functions/classes
- Include parameter descriptions
- Document return values
- Document exceptions raised
- Provide usage examples

## Changelog
- Follow Keep a Changelog format
- Group changes by type (Added, Changed, Fixed, Removed)
- Include version numbers and dates
- Link to relevant issues/PRs

## Forbidden
- Outdated documentation (must sync with code)
- Broken links
- Code examples that don't work
- Missing installation steps
- Undocumented breaking changes
