module Redcar
  module Scm
    module Subversion
      class Change
        include Redcar::Scm::ScmChangesMirror::Change
        include_package 'org.tmatesoft.svn.core.wc'
        include_package 'org.tmatesoft.svn.core'

        def initialize(path,status,children,diff_client)
          case Redcar.platform
          when :osx, :linux
            @path = path.gsub("//","/")
          when :windows
            @path = path.gsub("//","\\")
          end
          @status = status
          @children = children
          @diff_client = diff_client
        end

        def text
         File.basename(@path)
        end

        def tooltip_text
          @path
        end

        def icon
          case @status
          when :unmerged
            File.join(Redcar::ICONS_DIRECTORY, "blue-document--exclamation.png")
          when :indexed
            File.join(Redcar::ICONS_DIRECTORY, "blue-document--plus.png")
          when :deleted
            File.join(Redcar::ICONS_DIRECTORY, "blue-document-shred.png")
          when :changed
            File.join(Redcar::ICONS_DIRECTORY, "blue-document--pencil.png")
          when :missing
            File.join(Redcar::ICONS_DIRECTORY, "question-white.png")
          when :new
            if File.directory?(@path.to_s)
              :directory
            else
              :file
            end
          else
            :file
          end
        end

        def leaf?
          File.file?(@path)
        end

        def status
          [@status]
        end

        def log_status
          "#{log_codes[status] || ''} #{path}"
        end

        def path
          @path
        end

        def children
          @children
        end

        def diff
          unless @status == :new
            stream = Java::JavaIo::ByteArrayOutputStream.new
            file   = Java::JavaIo::File.new(path)
            @diff_client.doDiff(
              file, SVNRevision::BASE,
              file, SVNRevision::WORKING,
              SVNDepth::IMMEDIATES,
              false,
              stream,
              Java::JavaUtil::ArrayList.new
            )
            stream.toString()
          end
        end

        def log_codes
          {
            [:indexed]  => "A",
            [:changed]  => "M",
            [:deleted]  => "D",
            [:missing]  => "!",
            [:unmerged] => "C"
          }
        end
      end
    end
  end
end
