# TMTheme Editor
**TMTheme Editor** is a color scheme editor for [SublimeText][1], [Textmate][2] and bunch of other text editors.
It started as a personal experiment trying to use new HTML5 File APIs in Chrome and Angular.js. It allows you to edit `tmtheme` files easier and faster. 

**NOTE**: Only works in **Google Chrome** at the moment since HTML5 APIs it uses are not available in other browsers yet.

### TRY IT OUT HERE: [tmtheme-editor.herokuapp.com](http://tmtheme-editor.herokuapp.com/)

![](http://f.cl.ly/items/030L0A0j1M0l2a360w3r/tmtheme-editor-screenshot.png)

You can add your color scheme using the `Open` button (which does not upload anything to any server, but only allows the page to have access to the file. You can also drag and drop the file on to the page) and start tweaking the colors, add or remove rules and see the effect instantly on the preview pane. 

As soon as you add a color scheme to the editor it saves the file using the File System API so that you can refresh the page and still have the color scheme loaded. Whenever you're happy with your changes you can save them so that editor can persist it on the disk. To get back the new tmtheme file you can click `Download` button and use it in your editor.

## TmLanguage Parser
As a side project I started to write a tmLanguage parser in javascript to be able to highlight text files based on the color scheme inside the browser. it's a work in progress and has a lot of problems mainly because of javascript limited regular expression engine. I appreciate if you can help me improve it by sending a pull request. 

## Keyboard Shortcuts
`ctrl+n`: adds a new rule

`esc`: closes all the popovers

## HTML5 APIs used
- Blob constructing
- FileReader API
- fileWriter API
- filesystem API
- file saver API
- Drag and Drop API

written in [coffeescript](http://coffeescript.org/) using [angular.js](angularjs.org)


## Copyright
**TMThemeEditor**  
&copy; Copyright 2012 Allen Bargi

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

[1]: http://www.sublimetext.com/
[2]: http://macromates.com/