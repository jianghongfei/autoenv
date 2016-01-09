NOTE
=======

Cloned from [horosgrisa/autoenv](https://github.com/horosgrisa/autoenv), just make it compatible to bash.

Autoenv
=======

#### Autoenv automatically sources (known/whitelisted) `.env` and `.out` files.

This plugin support for enter and leave events. By default `.env` is used for entering, and `.out` for leaving. And you can set variable `COLORS=true` for enabling colored output.

## Example of use

- If you are in the directory `/home/user/dir1` and execute `cd /var/www/myproject` this plugin will source following files if they exist 
```
/home/user/dir1/.out
/home/user/.out
/home/.out
/var/.env
/var/www/.env
/var/www/myproject/.env
```

- If you are in the directory `/` and execute `cd /home/user/dir1` this plugin will source following files if they exist 
```
/home/.env
/home/user/.env
/home/user/dir1/.env
```

- If you are in the directory `/home/user/dir1` and execute `cd /` this plugin will source following files if they exist 
```
/home/user/dir1/.out
/home/user/.out
/home/.out
```

## Example of `.env` and `.out` files useful for node.js developing

### .env
```sh
OLDPATH=$PATH
export PATH=`pwd`/node_modules/.bin:$PATH

```

### .out
```sh
if [ -n "$OLDPATH" ]; then
    export PATH=$OLDPATH
    unset OLDPATH
fi

```

