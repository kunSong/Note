+ Sublime setting config

```
{
	"color_scheme": "Packages/Color Scheme - Default/Mariana.sublime-color-scheme",
	"font_face": "YaHei Consolas Hybird",
	"font_size": 11,
	"highlight_line": true,
	"overlay_scroll_bars": "enabled",
	"save_on_focus_lost": true,
	"tab_size": 4,
	"theme": "Adaptive.sublime-theme",
	"translate_tabs_to_spaces": true,
    "bold_folder_labels": true,
    "line_padding_bottom": 1,
    "line_padding_top": 1
}
```

+ install package control

```
// Ctrl+`
import urllib.request,os; pf = 'Package Control.sublime-package'; ipp = sublime.installed_packages_path(); urllib.request.install_opener( urllib.request.build_opener( urllib.request.ProxyHandler()) ); open(os.path.join(ipp, pf), 'wb').write(urllib.request.urlopen( 'http://sublime.wbond.net/' + pf.replace(' ','%20')).read())
```

+ fix sublime chinese input

```
git clone https://github.com/lyfeyaj/sublime-text-imfix.git
cd ~/sublime-text-imfix
sudo cp ./lib/libsublime-imfix.so /opt/sublime_text/ 
sudo cp ./src/subl /usr/bin/
```

+ short cut
  - 将文件保存为.cpp，然后Ctrl+shift+B即可编译运行
  - Ctrl+R定位函数
  - Ctrl+G定位到行
  - Ctrl+P可以定位文件
  - Ctrl+Shift+T可以打开之前关闭的tab

+ Mulit files make

```
{
	"shell_cmd": "make",
	"file_regex": "^(..[^:\n]*):([0-9]+):?([0-9]+)?:? (.*)$",
	"working_dir": "${folder:${project_path:${file_path}}}",
	"selector": "source.c, source.cpp",
	"syntax": "Packages/Makefile/Make.build-language",
	"keyfiles": ["Makefile", "makefile"],
	"variants":
	[
		{
			"name": "Make",
			"shell_cmd": "make"
		},
		{
			"name": "RunMake",
			"shell_cmd": "${file_path}/test"
		},
                {
			"name": "RunMakeInConsole",
			"shell_cmd": "gnome-terminal -x bash -c \"${file_path}/test;read -p 'Process Exit, Press any key to quit...'\"" 
                },
		{
			"name": "Make Clean",
			"shell_cmd": "make clean"
		},
		{
			"name": "RunSingleCpp",
			"shell_cmd": "g++ -Wall -std=c++11 \"${file}\" -o \"${file_path}/${file_base_name}\"&& '${file_path}/${file_base_name}'"
		},
		{
			"name": "RunSingleCppInConsole",
			"shell_cmd": "gnome-terminal -x bash -c \"if [ -f '${file_path}/${file_base_name}' ]; then rm '${file_path}/${file_base_name}'; fi; g++ -Wall -std=c++11 '${file}' -o '${file_path}'/'${file_base_name}'; '${file_path}'/'${file_base_name}'; read -p 'Process Exit, Press any key to quit...'\"" 
                }
		

	]
}
```
