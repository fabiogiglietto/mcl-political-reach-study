# Contributing to Meta Political Content Policy Analysis

Thank you for your interest in contributing to this research project! This document provides guidelines for contributing.

## Types of Contributions

### 1. Country Replications
The most valuable contributions are **replications of this study in other countries**. If you have MCL access and have analyzed political actors in your country, we'd love to include your findings.

**What to include:**
- Configuration file (`config/[country]_config.yaml`)
- Results summary with key findings
- Brief methodology notes documenting any country-specific adaptations

### 2. Code Improvements
Improvements to the analysis pipeline are welcome:
- Bug fixes
- Performance optimizations
- Better documentation
- New utility functions

### 3. Documentation
Help improve the documentation:
- Clarify confusing sections
- Add examples
- Fix typos
- Translate documentation

### 4. Methodological Suggestions
If you have suggestions for improving the methodology:
- Open an issue describing your suggestion
- Provide references to relevant literature
- If possible, demonstrate the improvement with data

---

## How to Contribute

### For Country Replications

1. **Fork the repository**
   ```bash
   git clone https://github.com/[username]/mcl-political-reach-study.git
   ```

2. **Create a branch for your country**
   ```bash
   git checkout -b replication/[country-code]
   ```

3. **Add your files:**
   - `config/[country]_config.yaml` - Your configuration
   - `outputs/results_summary_[country].yaml` - Key findings (optional)
   - Update `docs/REPLICATIONS.md` with your entry (if it exists)

4. **Submit a pull request** with:
   - Brief description of your replication
   - Key findings
   - Any methodology adaptations
   - Acknowledgment that you comply with MCL terms of service

### For Code Changes

1. **Fork and create a branch**
   ```bash
   git checkout -b feature/[description]
   ```

2. **Make your changes** following code style guidelines

3. **Test your changes** by running the full pipeline

4. **Submit a pull request** describing:
   - What the change does
   - Why it's needed
   - How you tested it

---

## Code Style Guidelines

### R Code
- Use tidyverse conventions
- Follow tidyverse style guide: https://style.tidyverse.org/
- Use meaningful variable names
- Add comments for complex operations
- Include function documentation with roxygen-style comments

```r
#' Brief description of function
#' 
#' Longer description if needed.
#' 
#' @param data Data frame input
#' @param threshold Numeric threshold value (default: 0.05)
#' @return Description of return value
#' @examples
#' result <- my_function(data, threshold = 0.01)
my_function <- function(data, threshold = 0.05) {
  # Implementation
}
```

### Documentation
- Use clear, concise language
- Include examples where helpful
- Keep formatting consistent with existing docs
- Update table of contents if adding sections

### Notebooks
- Include markdown cells explaining each step
- Clear output before committing (optional but preferred)
- Use consistent section headers

---

## Data and Privacy

### Critical Rules
1. **Never commit raw data** from Meta Content Library
2. **Never commit data containing personal information**
3. **Do not include identifiable account names** in committed outputs
4. **Follow all MCL Terms of Service**

### What CAN be committed
- Aggregated statistics (means, counts)
- Anonymized summaries
- Configuration files without sensitive IDs
- Code and documentation

---

## Pull Request Process

1. **Ensure compliance** with data privacy rules
2. **Test your changes** by running affected notebooks
3. **Update documentation** if your changes affect usage
4. **Request review** from a maintainer
5. **Address feedback** promptly

### PR Checklist
- [ ] No raw data or personal information included
- [ ] Code follows style guidelines
- [ ] Documentation updated (if applicable)
- [ ] All notebooks run successfully (if code changes)
- [ ] Configuration files use placeholders for sensitive values

---

## Reporting Issues

When reporting issues, please include:
- Description of the problem
- Steps to reproduce
- Expected vs. actual behavior
- R version and package versions
- Relevant error messages

For methodology questions, provide:
- Your research context
- Specific question or confusion
- What you've already tried

---

## Questions and Discussion

- **Issues:** For bugs, feature requests, specific questions
- **Discussions:** For general questions, methodology debates
- **Email:** For sensitive matters (see README for contact)

---

## Acknowledgment

Contributors will be acknowledged in:
- The repository README
- Any resulting publications (with permission)
- The CONTRIBUTORS.md file

---

## Code of Conduct

- Be respectful and inclusive
- Provide constructive feedback
- Assume good intentions
- Focus on the research goals

This is an academic research project. We welcome diverse perspectives and aim to maintain a welcoming environment for all contributors.

---

## License

By contributing to this project, you agree that your contributions will be licensed under the project's MIT License.

---

Thank you for contributing to open research on platform governance and political communication!
