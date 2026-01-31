FROM nikolaik/python-nodejs:python3.12-nodejs22-bookworm

ENV NODE_ENV=production

RUN curl -fsSL https://opencode.ai/install | bash -s -- --no-modify-path \
    && mv /root/.opencode/bin/opencode /usr/local/bin/opencode

# 复制 Agent 配置到工作目录
COPY agent/.opencode /root/workspace/.opencode
COPY agent/opencode.json /root/workspace/opencode.json
COPY agent/AGENTS.md /root/workspace/AGENTS.md

WORKDIR /root/workspace
EXPOSE 2442

CMD ["opencode", "web", "--port", "2442", "--hostname", "0.0.0.0"]
