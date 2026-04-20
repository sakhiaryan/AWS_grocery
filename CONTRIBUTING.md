# Contributing

Thanks for your interest in improving GroceryMate on AWS! 

## How to Contribute

1. **Fork** this repo and create your branch from `version2`.
   ```bash
   git checkout -b feature/my-improvement version2
   ```
2. **Make your changes**  keep commits small and focused.
3. **Run Terraform validation** if you touched IaC:
   ```bash
   cd infrastructure
   terraform fmt
   terraform validate
   ```
4. **Test locally** if you touched the app:
   ```bash
   docker-compose up --build
   curl -I http://localhost:5000
   ```
5. **Open a Pull Request** with a clear description and screenshots if UI-related.

## Commit Message Convention

We follow a loose [Conventional Commits](https://www.conventionalcommits.org) style:

- `feat:` new feature
- `fix:` bug fix
- `docs:` documentation only
- `chore:` tooling, CI, dependencies
- `refactor:` code change that neither fixes a bug nor adds a feature

Example:
```
feat(infrastructure): add CloudWatch alarm for ALB 5xx spikes
```

## Code of Conduct

Be kind. Assume good intent. Review with empathy.

## Reporting Issues

Use GitHub Issues. Please include:
- AWS region you used
- Terraform version (`terraform -version`)
- Docker version (`docker -v`)
- Steps to reproduce
- Expected vs. actual behaviour
