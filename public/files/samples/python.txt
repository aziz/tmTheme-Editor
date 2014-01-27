#!/usr/bin/python
# -*- coding: utf-8 -*-

import re
import sublime
import sublime_plugin
from datetime import datetime


class SublimeTasksBase(sublime_plugin.TextCommand):
    def run(self, edit):
        self.open_tasks_bullet = self.view.settings().get('open_tasks_bullet')
        self.done_tasks_bullet = self.view.settings().get('done_tasks_bullet')
        self.date_format = self.view.settings().get('date_format')
        if self.view.settings().get('done_tag'):
            self.done_tag = "@done"
        else:
            self.done_tag = ""
        self.runCommand(edit)


class NewCommand(SublimeTasksBase):
    def runCommand(self, edit):
        for region in self.view.sel():
            line = self.view.line(region)
            line_contents = self.view.substr(line).rstrip()
            has_bullet = re.match('^(\s*)[' + re.escape(self.open_tasks_bullet) + re.escape(self.done_tasks_bullet) + ']', self.view.substr(line))
            current_scope = self.view.scope_name(self.view.sel()[0].b)
            if has_bullet:
                grps = has_bullet.groups()
                line_contents = self.view.substr(line) + '\n' + grps[0] + self.open_tasks_bullet + ' '
                self.view.replace(edit, line, line_contents)
            elif 'header' in current_scope:
                header = re.match('^(\s*)\S+', self.view.substr(line))
                if header:
                    grps = header.groups()
                    line_contents = self.view.substr(line) + '\n' + grps[0] + ' ' + self.open_tasks_bullet + ' '
                else:
                    line_contents = ' ' + self.open_tasks_bullet + ' '
                self.view.replace(edit, line, line_contents)
                end = self.view.sel()[0].b
                pt = sublime.Region(end, end)
                self.view.sel().clear()
                self.view.sel().add(pt)
            else:
                has_space = re.match('^(\s+)(.*)', self.view.substr(line))
                if has_space:
                    grps = has_space.groups()
                    spaces = grps[0]
                    line_contents = spaces + self.open_tasks_bullet + ' ' + grps[1]
                    self.view.replace(edit, line, line_contents)
                else:
                    line_contents = ' ' + self.open_tasks_bullet + ' ' + self.view.substr(line)
                    self.view.replace(edit, line, line_contents)
                    end = self.view.sel()[0].b
                    pt = sublime.Region(end, end)
                    self.view.sel().clear()
                    self.view.sel().add(pt)











