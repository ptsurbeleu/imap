# NOTES:
# - Removing cache.ets has been added to fix up annoying issue with the following error occasionally surfacing to stdout:
#   > "Error opening ETS file $HOME/.hex/cache.ets: :badfile"
restore :
	@printf "\033[36m~> mix deps.get\033[0m\n"
	@rm ~/.hex/cache.ets && mix deps.get

compile : restore
	@printf "\033[36m~> mix compile --warnings-as-errors\033[0m\n"
	@mix compile --warnings-as-errors

test : restore
	@printf "\033[36m~> mix test\033[0m\n"
	@mix test

format : restore
	@printf "\033[36m~> mix format --check-formatted\033[0m\n"
	@mix format --check-formatted

lint : restore
	@printf "\033[36m~> mix credo --strict\033[0m\n"
	@mix credo --strict

docs : restore
	@printf "\033[36m~> mix docs\033[0m\n"
	@mix docs

validate : compile test format lint docs

.PHONY : compile test format lint validate restore docs