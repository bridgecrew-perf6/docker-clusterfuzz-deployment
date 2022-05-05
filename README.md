I had a heck of a time trying to get Clusterfuzz deployed. Version mismatches, things being deprecated, but then because clusterfuzz checks its repo to make sure its up to date, you can't patch them.

Just a few of the issues I had:

- Conflicting version requirements, part of it requires I downgrade to py3.7-3.9, later, only 3.7 is supported (`butler.py deploy`).
 - Resolved by adding the deadsnakes/ppa repository for apt and installed `python3.7`. Later I also needed `python3.7-dev` and `python3.7-distutils`.
- node/npm used by `nodeenv --prebuilt` needed a newer glibc than could be installed on Ubuntu 16.04-18.10 
 - Ubuntu 20.04 has worked out for me with this docker container
- `polymer-bundler` would fail to be installed. The actual error was it trying to run a missing postinstall script, not sure why it was missing but it seemed to be because of a requirement on a deprecated core-js version.
 - Solved this by installing a newer polymer-bundler into /tmp and just copying the node_modules folder into the clusterfuzz nodeenv and linking the binary manually.Not ideal, but none of the node_modules appeared to collide so seems reasonably safe and had no issues during deployment so the binary interface didn't change. 


Anyway, lots of fun getting this. In theory now under docker its somewhat reproducible though so I figured I'd share.

### Setup

You do need to provide a few things, the `run.sh` script expects two folders:

1. `./files` - This gets mounted to `/files` and should contains three files:
 - Your oauth secrets json file
 - The AppEngine service account key file (json)
 - envrionment.txt (more on this shortly)
2. `./config` - It'll try to make this folder, it should be empty at first, and will be filled in by `/scripts/make_config.sh` which runs the butler `make_config` script.

**./files/envrionment.txt**

This is where you define all the envrionment variaibles that the clusterfuzz production setup mentions:
 - FIREBASE_API_KEY=[key here]
 - CLIENT_SECRETS_PATH=/files/oauth.secrets.json
 - CONFIG_DIR=/config
 - CLOUD_PROJECT_ID=example-project

And there are a couple others needed that don't get mentioned:
- GOOGLE_APPLICATION_CREDENTIALS=/files/service_account.json
- USER=underscorezi

The USER one can be anything, git complains at one point when its not set.

### Deploying

- Build the image. This will need to be repeated with each clusterfuzz update since the git repo needs to be on latest.
- Start the container with `./run.sh` - this will spawn a temporary container with the clusterfuzz envrionment with `/files` and `/config` mounted and using the `./files/environment.txt` file.
- If you do not already have all the config files creates in `./config` run `/scripts/make_config.sh`
 - This will first do a `gcloud auth login` so the `gcloud` cli is authenticated. 
 - Then it'll execute the `butler.py make_config` script that the clusterfuzz docs mention.
- Modify the `./config` contents as you want.
- Run the `/scripts/deploy.sh` script
 - Like `make_config.sh` it starts off with the `gcloud auth login` and then runs the `deploy` butler script.

After all this, you should have clusterfuzz deployed. Don't worry if the deploy seems stuck after/during the uploading files step. Its still doing things even when its apparently done.