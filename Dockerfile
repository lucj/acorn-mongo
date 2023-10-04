FROM mongo:6.0
COPY ./scripts/render.sh /acorn/scripts/render.sh
ENTRYPOINT ["/acorn/scripts/render.sh"]