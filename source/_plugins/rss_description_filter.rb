require "loofah"

module Jekyll
  module RSSDescriptionFilter
    ATTRIBUTE_BLACKLIST = ["class", "id", "style"]
    NODE_BLACKLIST = ["form", "link", "style"]

    class Scrubber < Loofah::Scrubber
      def scrub(node)
        remove_unwanted_attributes(node)

        # Remove unwanted nodes
        return CONTINUE if allowed_node?(node)

        node.remove
        STOP
      end

      private

      def allowed_node?(node)
        !unwanted_node?(node) && !comment?(node)
      end

      def comment?(node)
        node.is_a?(Nokogiri::XML::Comment)
      end

      def data_attribute?(name)
        name.to_s[0, 5] == "data-"
      end

      def remove_unwanted_attributes(node)
        # Remove unwanted attributes
        node.attributes.each do |name, _|
          node.remove_attribute(name) if unwanted_attribute?(name)
        end
      end

      def unwanted_attribute?(name)
        data_attribute?(name) || ATTRIBUTE_BLACKLIST.include?(name)
      end

      def unwanted_node?(node)
        NODE_BLACKLIST.include?(node.name)
      end
    end

    # Returns input sanitized for output in a RSS description tag.
    #
    # Removes comments, data-attributes as well as blacklisted attributes and
    # nodes.
    def html_to_rss_description(input)
      html = Loofah.fragment(input)
      html.scrub!(Scrubber.new)
      html.to_s
    end
  end
end

Liquid::Template.register_filter(Jekyll::RSSDescriptionFilter)
