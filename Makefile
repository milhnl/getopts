.POSIX:
.PHONY: test

test:
	for x in bash dash zsh; do \
		if [ -z "$$(command -v "$$x" 2>/dev/null)" ]; then \
			printf "Shell %s was not found and could not be tested\n" \
				"$$x" >&2; \
		else \
			"$$x" test.sh; \
		fi \
	done
