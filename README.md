# Consul Config Loader

[![Build Status][travis-image]][travis-url]

A small docker based tool to load Spring Boot property files into Consul K/V Store. It features hot-reload as well as filesystem and git support.

## Filesystem mode

In this mode, the **consul-config-loader** agent pushes all YAML properties files in the `config/` directory to consul K/V store. It automatically detects when files are added or edited to reload them into Consul.

To use this mode, configure those properties in `bootstrap.yml`:
```
spring:
    cloud:
        consul:
            config:
                format: yaml
                profile-separator: "-"
```
Then run `docker-compose -f quickstart/consul-loader-filesystem.yml up` to start a Consul server on localhost and and its
 agent.
You can then access [http://localhost:8500/ui/#/dc1/kv/config/](http://localhost:8500/ui/#/dc1/kv/config/) and watch as your Consul K/V store is synchronised with property files in the `config/` directory.

# Git mode

To use this mode, configure those properties in `bootstrap.yml`:
```
spring:
    cloud:
        consul:
            config:
                fail-fast: true
                format: files
                profile-separator: "-"
```
This mode is recommended for production, it is a wrapper around [git2consul](https://github.com/Cimpress-MCP/git2consul) project.
You will have to configure the `config/git2consul.json` file to have it load its configuration from your own git repository.

Simply run `docker-compose -f quickstart/consul-loader-git.yml up` to start Consul and the agent.

# ACL security

To maintain security for KV access and service discovery, this config loader expects consul running with ACL enabled, which leads to the presence of a master ACL token (refered to the loader by environment variable MASTER_ACL_TOKEN). This token is used, to **create** a client ACL token (provided by CLIENT_ACL_TOKEN variable), with a default policy and for writing config changes. 
The default policy for the client ACL is to permit read to KV and write to service discovery. This policy can be changed using the [HTTP API for ACL](https://www.consul.io/docs/agent/http/acl.html) for custom policies. It is strongly recommended to use some random strings (like UUID) for the token values. MASTER_ACL_TOKEN and CLIENT_ACL_TOKEN must not be equal.

To make JHipster or Spring Cloud applications registering to consul using the ACL, just add the client ACL token to bootstrap.yml:

```
consul:
    token: my-client-acl-token

```

- [Spring Cloud Consul docs](https://cloud.spring.io/spring-cloud-consul/#spring-cloud-consul-config)
- [Consul K/V store API docs](https://www.consul.io/docs/agent/http/kv.html)
- [Git2consul docs](https://github.com/Cimpress-MCP/git2consul)


[travis-image]: https://travis-ci.org/jhipster/consul-config-loader.svg?branch=master
[travis-url]: https://travis-ci.org/jhipster/consul-config-loader
