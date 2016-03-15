#!/usr/bin/env ruby
# frozen_string_literal: true
#
# Copyright (C) 2016 Harald Sitter <sitter@kde.org>
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) version 3, or any
# later version accepted by the membership of KDE e.V. (or its
# successor approved by the membership of KDE e.V.), which shall
# act as a proxy defined in Section 6 of version 3 of the license.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library.  If not, see <http://www.gnu.org/licenses/>.

require 'pathname'
require 'pp'

class Origin
  attr_accessor :filetype

  def initialize(pathname)
    @pathname = pathname
    @filetype = '.png'
  end

  def size
    name = @pathname.dirname.basename
    raise "found scalable link, can't process" if name == 'scalable'
    name
  end

  def basename
    @pathname.basename.to_s.gsub('.svg', @filetype)
  end

  def type
    @pathname.dirname.dirname.basename
  end

  def relative_dir
    return "#{size}x#{size}/#{type}" if filetype == '.png'
    "scalable/#{type}"
  end

  def absolute_dir
    File.absolute_path(relative_dir)
  end

  def relative_path
    "#{relative_dir}/#{basename}"
  end

  def absolute_path
    File.absolute_path(relative_path)
  end
end

class Symlink
  attr_reader :origin
  attr_reader :target
  attr_reader :real_target

  def initialize(origin)
    origin = File.absolute_path(origin)
    target = File.readlink(origin)
    @origin = Pathname.new(origin)
    @target = Pathname.new(target)
    @real_target = @target.realpath(@origin.dirname) # resolve
  end

  def pixel_compatible?
    same_size?
  end

  def same_size?
    @origin.dirname.basename == @real_target.dirname.basename
  end
end

files = Dir.glob('../breeze-icons/icons/**/**')
files.reject! { |file| !File.symlink?(file) }
files.uniq!
files.compact!
files.collect! { |file| File.absolute_path(file) }

rejected = 0
symlinks = files.collect { |file| Symlink.new(file) }
symlinks.reject! do |symlink|
  reject = !symlink.pixel_compatible?
  if reject
    puts 'cannot replicate symlink because the size is different between the link parts'
    puts '----'
    puts symlink.inspect
    rejected += 1
  end
  reject
end

missing_targets = 0
existing_symlinks = 0
existing_files = 0

symlinks.each do |symlink|
  origin = Origin.new(symlink.origin)
  target = Origin.new(symlink.real_target)

  unless File.exist?(target.absolute_path)
    warn "#{target.relative_path} does not exist"
    warn "wanted to link #{origin.relative_path} to it"
    puts '----'
    missing_targets += 1
    next
  end

  link_target = Pathname.new(target.absolute_path).relative_path_from(Pathname.new(origin.absolute_dir))
  Dir.chdir(origin.relative_dir) do
    if File.symlink?(origin.basename)
      existing_symlinks += 1
      next
    end
    if File.file?(origin.basename)
      existing_files += 1
      next
    end
    File.symlink(link_target, origin.basename)
  end
end

puts "rejected: #{rejected} (because of size mismatch between target and source)"
puts "accepted: #{symlinks.size} (tried to link this many files)"
puts "missing: #{missing_targets} (where we wanted to link to was missing)"
puts "existing link: #{existing_symlinks} (these symlinks existed already)"
puts "existing file: #{existing_files} (these files existed already)"
puts "replicated: #{symlinks.size - missing_targets - existing_symlinks - existing_files} (total)"
# pp symlinks
