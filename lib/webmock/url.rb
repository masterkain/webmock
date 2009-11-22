module WebMock

  class URL

    def self.normalize_uri(uri)
      return uri if uri.is_a?(Regexp)
      uri = 'http://' + uri unless uri.match('^https?://') if uri.is_a?(String)
      normalized_uri = Addressable::URI.heuristic_parse(uri)
      normalized_uri.query_values = normalized_uri.query_values if normalized_uri.query_values
      normalized_uri.normalize!
      normalized_uri.port = normalized_uri.inferred_port unless normalized_uri.port && normalized_uri.inferred_port 
      normalized_uri
    end

    def self.variations_of_uri_as_strings(uri_object)
      normalized_uri = normalize_uri(uri_object.dup).freeze
      uris = [ normalized_uri ]
      
      if normalized_uri.port == Addressable::URI.port_mapping[normalized_uri.scheme]
        uris = uris_with_inferred_port_and_without(uris)
      end
      
      if normalized_uri.scheme == "http"
        uris = uris_with_scheme_and_without(uris)
      end
      
      if normalized_uri.path == '/' && normalized_uri.query == nil
        uris = uris_with_trailing_slash_and_without(uris)
      end
      
      uris = uris_encoded_and_unencoded(uris)

      uris.map {|uri| uri.to_s.gsub(/^\/\//,'') }.uniq
    end

    private

    def self.uris_with_inferred_port_and_without(uris)
      uris.map { |uri| [ uri, uri.omit(:port).freeze ] }.flatten
    end

    def self.uris_encoded_and_unencoded(uris)
      uris.map do |uri|
        [ uri, Addressable::URI.heuristic_parse(Addressable::URI.unencode(uri)).freeze ]
      end.flatten
    end

    def self.uris_with_scheme_and_without(uris)
      uris.map { |uri| [ uri, uri.omit(:scheme).freeze ] }.flatten
    end

    def self.uris_with_trailing_slash_and_without(uris)
      uris = uris.map { |uri| [ uri, uri.omit(:path).freeze ] }.flatten
    end

  end

end