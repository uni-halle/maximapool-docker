# MaximaPool

Docker-ized version of [**MaximaPool**](https://github.com/maths/stack_util_maximapool).

> The MaximaPool creates a pool of maxima processes.
> This has a number of advantages on large production sites,
> including the ability to put maxima processes on a
> separate server, or servers.
> Also, pooling helps starting up maxima processes so that
> STACK does not need to wait for them, this may save over
> 250ms each time you have to call maxima.

STACK-maxima in this image is highly optimized. Before using the pool, one shell call to Maxima took around 4s, now it's at about 100ms, or 200ms with request overhead.

* Code on [GitHub](https://github.com/uni-halle/maximapool-docker) ([Issues](https://github.com/uni-halle/maximapool-docker/issues))
* Image on [Docker Hub](https://hub.docker.com/r/unihalle/maximapool)
* Author: Dockerization: Abt. Anwendungssysteme, [ITZ Uni Halle](http://itz.uni-halle.de/); Image includes various open source software.
  See Dockerfile for details.
* Support: As a **university** or **research facility** you might be successful in requesting support through the **[ITZ Helpdesk](mailto:helpdesk@itz.uni-halle.de)** (this can take some time) or contacting the author directly. For **any other entity**, including **companies**, see [my home page](https://wohlpa.de/) for contact details and pricing. You may request hosting, support or customizations.
  *Reporting issues and creating pull requests is always welcome and appreciated.*

## Which version/ tag?

There are multiple versions/ tags available under [dockerhub:unihalle/maximapool/tags/](https://hub.docker.com/r/unihalle/maximapool/tags/).

| Tag                | STACK version | OS/Tomcat/JRE   | Maxima version | assStackQuestion | ILIAS | moodle-qtype_stack |
|:------------------ | -------------:| --------------- | --------------:| ----------------:| ----- | ------------------ |
| `latest`           | 2018030500    | debian sid/9/11 | 5.41.0-Linux   |                  |       |4.1+ [(9bf7a7f)](https://github.com/maths/moodle-qtype_stack/tree/9bf7a7ff6118086480f2b3db5fbb933150c8fa49)
| `stack-2018030500` | 2018030500    | debian sid/9/11 | 5.41.0-Linux   |                  |       |4.1+ [(9bf7a7f)](https://github.com/maths/moodle-qtype_stack/tree/9bf7a7ff6118086480f2b3db5fbb933150c8fa49)
| `stack-2017121800` | 2017121800    | debian sid/9/10 | 5.41.0-Linux   | 12439ff          | 5.3   |4.1
| `stack-2014083000` | 2014083000    | debian sid/9/9  | 5.41.0-Linux   | c23c787 / 9a42ef8 [with patch](https://github.com/ilifau/assStackQuestion/issues/32) | 5.0-5.1 / 5.2 |3.3

### Identifying required version

**ILIAS (assStackQuestion)**

Run `$(grep stackmaximaversion ${ILIAS_PLUGIN_STACK}/classes/stack/maxima/stackmaxima.mac | grep -oP "\d+")` with `${ILIAS_PLUGIN_STACK}` being an absolute or relative path to the assStackQuestion plugin directory.

**Moodle (moodle-qtype_stack)**

Run `$(grep stackmaximaversion $MOODLE/question/type/stack/stack/maxima/stackmaxima.mac | grep -oP "\d+")` with `$MOODLE` being the root directory of the moodle site on the server.

## Caveats

* Do not allow direct access from any untrusted users to services/containers created from this image. You may reverse proxy requests through HTTP (basic) auth. Example below.
* There might be trouble running with containers created from this image when **`aufs`** is docker's [storage driver](https://docs.docker.com/engine/userguide/storagedriver/selectadriver/). You can check with `docker info` for your storage driver in use. For Debian and Ubuntu, as of 2018, we recommend overlay2 instead. 

## Usage

Create the following files:

`volumes/pool.conf` (Please adjust the values as to meet your requirements and make sure the file is readeable by everyone [chmod o+r].):
```
# Configuration for maxima pool
# Times in milliseconds

# Size limits
size.min = 5
size.max = 15

# This is the limit of simultaneously starting processes this combined to the update frequency defines the maximum load
start.limit = 4

# Pool update cycle (ms between updates)
update.cycle = 500

# How big a data-set should be kept for estimates, do not make this too big if the usage is not nearly constant.
adaptation.averages.length = 5

# Pool size depends on the demand and startuptimes the system tries to maintain the minimum size but as demand may vary one should use a multiplier to play it safe.
adaptation.safety.multiplier = 3.0
```

`.env`:
```
MAXIMAPOOL_ADMIN_PASSWORD=PUT A STRONG SECRET PASSWORD HERE!
```

### Running using Docker only

```
docker run -d \
   --name TestMaximaPool \
   --env-file .env \
   -p "8765:8080" \
   -v "/path/to/volumes/pool.conf:/opt/maximapool/pool.conf:ro" \
   unihalle/maximapool
```

You can now visit your pool at http://host:8765/MaximaPool/MaximaPool

### Running using docker-compose

Minimal example (binds port 8765 to localhost):

`docker-compose.yaml`:
```
version: "2"
services:
  maximal-pool:
    image: unihalle/maximapool:stack-2017121800
    restart: always
    environment:
        - MAXIMAPOOL_ADMIN_PASSWORD
    ports:
        - "127.0.0.1:8765:8080"
    volumes:
        - "./volumes/pool.conf:/opt/maximapool/pool.conf:ro"
```

You can now look at your pool at http://127.0.0.1:8765/MaximaPool/MaximaPool
Inside the docker-compose network, the URL is `http://maximal-pool:8080/MaximaPool/MaximaPool`.

### Using a proxy with HTTP basic auth and certificates

This is a complete example illustrating the use with a reverse proxy providing HTTP password authentication and encryption inside a network managed by docker-compose. Please replace `$VIRTUAL_HOST` with an actual host name.

The disadvantage of HTTP basic auth is that the password is hashed on every request. If you choose more heavy hashing (>8) you are likely to slow down your web proxy.

```
# Create the pool.conf and .env as described in the minimal examples

# Create an htpasswd file (requires apache-utils installed)
mkdir -p passwords && htpasswd -cBC 8 passwords/$VIRTUAL_HOST ${USER}
# Alternatively use: docker run --rm httpd htpasswd -nbB ${USER} ${PASSWORD} > passwords/$VIRTUAL_HOST

# Add certificates so they can be read by the reverse proxy
mkdir -p certs && cp VIRTUAL_HOST.crt certs/ && cp VIRTUAL_HOST.key certs/
```

`docker-compose.yaml`:
```
version: "2"
services:
  maximal-pool:
    image: unihalle/maximapool:stack-2017121800
    restart: always
    environment:
        - MAXIMAPOOL_ADMIN_PASSWORD
        - VIRTUAL_HOST=$VIRTUAL_HOST
        - VIRTUAL_PORT=8080
    volumes:
        - "./volumes/pool.conf:/opt/maximapool/pool.conf:ro"
        - "/etc/localtime:/etc/localtime:ro"
  reverse-proxy:
    image: jwilder/nginx-proxy:alpine
    environment:
        - DEFAULT_HOST=$VIRTUAL_HOST
    ports:
      - "8065:80"
      - "8765:443"
    restart: always
    volumes:
      - /var/run/docker.sock:/tmp/docker.sock:ro
      - ./certs:/etc/nginx/certs:ro
      - ./passwords:/etc/nginx/htpasswd:ro
```

Finally bring it up and watch the logs:
`docker-compose up -d && docker-compose logs -f`

You can now look at your pool at https://$VIRTUAL_HOST:8765/MaximaPool/MaximaPool after you were prompted for your password if you have configured everything correctly.

Hit `Ctrl`+`C` to quit the logs.

### Multiple/ Custom STACK versions

It is possible running this container with multiple versions of STACK or having multiple pools: Mount a volume with proper contents and permissions to `/opt/maximapool/%%VERSION%%/`. You might use the container itself to generate your custom STACK-maxima pool. Toolchain, lisp and maxima are already installed.

It is also possible to build image for use with specific version of Moodle [Question Type STACK plugin](https://github.com/maths/moodle-qtype_stack). Make sure that `assets/moodle-qtype_stack` submodule is tracking commit that is matching the version of `qtype_stack` plugin you have installed in Moodle, then build the image with `--build-arg BUILD_FOR_MOODLE=1` parameter.

## Using with Moodle

On the Moodle side, STACK configuration is located at Site Administration -> Plugins -> Question Type -> STACK plugin settings. To make it worh with MaximaPool Docker container, you need to set:
* Platform type: Server
* Maxima version: choose one matching the image in use (e.g. 5.41.0)
* Maxima command: `maxima-pool:8080/MaximaPool/MaximaPool`

`maxima-pool` is the hostname of Maxima container, it should be accessible by Moodle webserver.

## Contributing

* Advice on [writing docker files](https://developers.redhat.com/blog/2016/02/24/10-things-to-avoid-in-docker-containers/).
* Releasing a new version:
    1. Release it to a new branch.
    2. Update this README.md's compatibility matrix.
    3. Generate a new `/data_dir/xqcas/stack/maximalocal.mac` through plugin update and re-configuration.
    4. Update assets/maximalocal.mac.template and assets/optimize.mac with generated values from `/data_dir/xqcas/stack/maximalocal.mac` [ILIAS] or `$MOODLEDATA/stack/**/maximalocal.mac` [Moodle].

## For developers: Locating, tracking and amending versions

### Locate stackmaxima
- Moodle [stackmaxima.mac](https://github.com/maths/moodle-qtype_stack/blob/master/stack/maxima/stackmaxima.mac): Last line
- ILIAS [stackmaxima.mac](https://github.com/ilifau/assStackQuestion/blob/master/classes/stack/maxima/stackmaxima.mac): Last line

### Change stackmaxima
- Moodle: `cd assets/moodle-qtype_stack && git checkout [ref] && cd ../.. && git add assets/moodle-qtype_stack && git commit -m "Update to STACK [stackversion]"`
   Impacts moodle-qtype_stack [`cd assets/moodle-qtype_stack && git log`]  version.
- ILIAS: `cd assets/assStackQuestion && git checkout [ref] && cd ../.. && git add assets/assStackQuestion && git commit -m "Update to STACK [stackversion]"`
  Impacts assStackQuestion [`cd assets/assStackQuestion && git log`] and possibly ILIAS version. assStackQuestion has branches like `master-ilias53`

### Locate OS
- `docker-compose exec [maximapool] bash -c 'cat /etc/debian_version'`
- Look up in [Wikipedia](https://en.wikipedia.org/wiki/Debian_version_history)
- Depends on the base image used for Tomcat/JDK

### Locate and amend Tomcat / JDK version
- See [Dockerfile](https://github.com/uni-halle/maximapool-docker/blob/develop/Dockerfile) first line.

### Locate and amend Maxima version
- See [Dockerfile](https://github.com/uni-halle/maximapool-docker/blob/develop/Dockerfile) and grep for "Maxima-Linux".

### Files to monitor for changes

- assets/optimize.mac
  - Watch for _This variable controls which optional packages are supported by STACK._
  - Moodle [stack/cas/installhelper.class.php#L32](https://github.com/maths/moodle-qtype_stack/blob/master/stack/cas/installhelper.class.php#L32)
  - ILIAS [classes/stack/cas/installhelper.class.php#L37](https://github.com/ilifau/assStackQuestion/blob/629f817624b1dfb7cbb74aa0f1135c0ad39c56df/classes/stack/cas/installhelper.class.php#L37)
  - and ensure all these packages are loaded
  - it's easier to look into an LMS generated stackmaxima.mac file.
- assets/maximalocal.mac.template
  - Moodle [stack/maxima/sandbox.wxm](https://github.com/maths/moodle-qtype_stack/blob/1130d860ebb8e03d78c6c7973ba48c2dfa844685/stack/maxima/sandbox.wxm) - only as a hint - you should really look into an LMS generated stackmaxima.mac file.
   - ILIAS [classes/stack/maxima/sandbox.wxm](https://github.com/ilifau/assStackQuestion/blob/629f817624b1dfb7cbb74aa0f1135c0ad39c56df/classes/stack/maxima/sandbox.wxm) - only as a hint - you should really look into an LMS generated stackmaxima.mac file.
