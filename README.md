#LUTIm

##What LUTIm means?
It means Let's Upload That Image.

##What does it do?
It stores images and allows you to see them or download them.
Images are indefinitly stored unless you request that they will be deleted at first view or after 24 hours.

##License
LUTIm is licensed under the terms of the AGPL. See the LICENSE file.

##Logo
LUTIm's logo is an adaptation of [Lutin](http://commons.wikimedia.org/wiki/File:Lutin_by_godo.jpg) by [Godo](http://godoillustrateur.wordpress.com/), licensed under the terms of the CC-BY-SA 3.0 license.

![LUTIm's logo](http://lut.im/img/LUTIm_small.png)

##Dependancies
* Carton : Perl dependancies manager, it will get what you need, so don't bother for dependancies (but you can read the file `cpanfile` if you want).

```shell
sudo cpan Carton
```

##Installation
After installing Carton :
```shell
git clone https://github.com/ldidry/lutim.git
cd lutim
carton install
cp lutim.conf.template lutim.conf
```

##Usage
```
carton exec hypnotoad script/lutim
```

Yup, that's all (Mojolicious magic), it will listen at "http://127.0.0.1:8080".

For more options (interfaces, user, etc.), change the configuration in `lutim.conf` (have a look at http://mojolicio.us/perldoc/Mojo/Server/Hypnotoad#SETTINGS for the available options).

##Reverse proxy
You can use a reverse proxy like Nginx or Varnish (or Apache with the mod\_proxy module). The web is full of tutos.

Here's a valid *Varnish* configuration:
```
backend lutim {
    .host = "127.0.0.1";
    .port = "8080";
}
sub vcl_recv {
    if (req.restarts == 0) {
        set req.http.X-Forwarded-For = client.ip;
    }
    if (req.http.host == "lut.im") {
        set req.backend = lutim;
        return(pass);
    }
}
```

##Shutter integration
See where Shutter (<http://en.wikipedia.org/wiki/Shutter_%28software%29>) keeps its plugins on your computer.
On my computer, it's in `/usr/share/shutter/resources/system/upload_plugins/upload`.

Then:
```
sudo cp utilities/Shutter.pm /usr/share/shutter/resources/system/upload_plugins/upload/Lutim.pm
```

And restart Shutter if it was running.

Of course, this plugin is configured for the official instance of LUTIm (<http://lut.im>), feel free to edit it for your own instance.

##Internationalization
LUTIm comes with english and french languages. It will choose the language to display from the browser's settings.

If you want to add more languages, for example german:
```shell
cd lib/I18N
cp en.pm de.pm
vim de.pm
```

There's just a few sentences, so it will be quick to translate. Please consider to send me you language file in order to help the other users :smile:.

##Others projects dependancies
LUTIm is written in Perl with the Mojolicious framework, uses the Twitter bootstrap framework to look not too ugly, JQuery and JQuery File Uploader (<https://github.com/danielm/uploader/>) to add some modernity.

##Official instance
You can see it working at http://lut.im.
