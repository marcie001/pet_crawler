# -*- encoding: UTF-8 -*-
require 'MeCab'

class MorphologicalAnalysis

    # 
    # 利用する品詞ID 
    # 
    POSIDS = [38, 41, 42, 43, 44, 45, 46, 47]

    def initialize
        @mecab = MeCab::Tagger.new
    end

    #
    # 形態素解析し一般名詞、固有名詞を返す
    #
    def parse_to_node(value)
        nodes = @mecab.parseToNode(value)
        tags = []
        while nodes do
            if (POSIDS.include?(nodes.posid)) then
                tags.push(nodes.surface.to_s.force_encoding(Encoding::UTF_8))
            end
            nodes = nodes.next
        end
        tags
    end
end
