module ZergXcode # :nodoc:


class FileReferenceBuilder

  FILE_TYPES = {
    '.app' => 'wrapper.application',
    '.framework' => 'wrapper.framework',
    '.h' => 'sourcecode.c.h',
    '.m' => 'sourcecode.c.objc',
    '.mm' => 'sourcecode.cpp.objcpp',
    '.plist' => 'text.plist.xml',
    '.strings' => 'text.plist.strings',
    '.xib' => 'file.xib',
  }

  def initialize(path)
    @path = path
  end

  def build
    ZergXcode::XcodeObject.new 'isa' => :PBXFileReference,
                               'name' => reference_name,
                               'path' => reference_path,
                               'fileEncoding' => 4,
                               'sourceTree' => '<group>',
                               'lastKnownFileType' => last_known_file_type
  end

  def reference_name
    File.basename path
  end
  private :reference_name

  def reference_path
    File.basename path
  end
  private :reference_path

  def last_known_file_type
    FILE_TYPES[extension] || "file#{extension}"
  end
  private :last_known_file_type

  def extension
    File.extname path
  end
  private :extension

  def path
    @path
  end
  private :path

end


end
