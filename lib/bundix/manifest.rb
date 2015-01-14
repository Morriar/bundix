require 'bundix'

class Bundix::Manifest
  attr_reader :gems

  def initialize(gems)
    @gems = gems.sort_by { |g| g.name }
  end

  def to_nix
    template = File.read(__FILE__).split('__END__').last.strip
    ERB.new(template, nil, '->').result(binding)
  end
end

__END__
{
  <%- gems.each do |gem| -%>
  "<%= gem.inspect %>" = {
    version = "<%= gem.version %>";
    src = {
      type = "<%= gem.source.type %>";
      <%- if gem.source.type == 'git' -%>
      url = "<%= gem.source.url %>";
      rev = "<%= gem.source.revision %>";
      fetchSubmodules = <%= gem.source.submodules %>;
      sha256 = "<%= gem.source.sha256 %>";
      <%- elsif gem.source.type == 'gem' -%>
      sha256 = "<%= gem.source.sha256 %>";
      <%- elsif gem.source.type == 'path' -%>
      path = <%= gem.source.path %>;
      <%- end -%>
    };
    <%- if gem.dependencies.any? -%>
    dependencies = [
      <%= gem.dependencies.sort.map {|d| d.inspect}.join("\n      ") %>
    ];
    <%- end -%>
  };
  <%- end -%>
}
