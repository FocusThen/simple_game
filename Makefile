build:
	@odin build cmd -out:bin/simple_game -build-mode:exe

run: build
	@./bin/simple_game
