.PHONY: lint lint-fix run test jest db-migrate db-seed db-create db-drop db-reset install e2e
lint:
	@echo "💻 Running RuboCop linter..."
	@bin/rubocop -f github || { \
		echo "❌ RuboCop found offenses"; \
		exit 1; \
	}
	@echo "✅ RuboCop passed"

lint-fix:
	@echo "🛠 Running RuboCop with auto-fix..."
	bin/rubocop -f github --autocorrect-all
	@echo "✅ Lint fixes applied"

run: install
	bin/dev

e2e: install
	bundle exec rails test:system 

test: install
	npx jest
	rails test

jest: install
	npx jest

db-create:
	bin/rails db:create

db-drop:
	bin/rails db:drop

db-migrate:
	bin/rails db:migrate

db-seed:
	bin/rails db:seed

db-reset: db-drop db-create db-migrate db-seed

install:
	bundle install
