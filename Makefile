build:
	@docker build --build-arg USERNAME="$(USER)" --build-arg UID="$(shell id -u)" --build-arg HOME="$(HOME)" --progress plain -t ansible-container .

run:
	@docker run --rm -it --env-file .env  --mount type=bind,source="$(HOME)/.ssh",dst="$(HOME)/.ssh" --mount type=bind,source="$(shell pwd)"/,dst=/ansible ansible-container sh

lint:
	@docker run --rm -it --mount type=bind,source="$(shell pwd)"/,dst=/ansible ansible-container sh -c 'echo "----------- ansible-lint --------------" && ansible-lint playbooks/ && echo "----------- ansible-lint --------------" && echo "----------- yamllint --------------" && yamllint . && echo "----------- yamllint --------------"'
