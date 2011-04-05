<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:df="http://dita2indesign.org/dita/functions"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:relpath="http://dita2indesign/functions/relpath"
                xmlns:htmlutil="http://dita4publishers.org/functions/htmlutil"
                xmlns:index-terms="http://dita4publishers.org/index-terms"
                xmlns:local="urn:functions:local"
                exclude-result-prefixes="local xs df xsl relpath htmlutil index-terms"
  >
  <!-- =============================================================
    
    DITA Map to HTML Transformation
    
    Dynamic ToC generation. This transform generates the HTML markup
    and JavaScript for a dynamic table of contents.
    
    Copyright (c) 2010 DITA For Publishers
    
    Licensed under Common Public License v1.0 or the Apache Software Foundation License v2.0.
    The intent of this license is for this material to be licensed in a way that is
    consistent with and compatible with the license of the DITA Open Toolkit.
    
    This transform requires XSLT 2.
    ================================================================= -->    
  <xsl:import href="../../net.sourceforge.dita4publishers.common.xslt/xsl/lib/dita-support-lib.xsl"/>
  <xsl:import href="../../net.sourceforge.dita4publishers.common.xslt/xsl/lib/relpath_util.xsl"/>
  
  <xsl:import href="../../net.sourceforge.dita4publishers.common.xslt/xsl/lib/html-generation-utils.xsl"/>
  
  <xsl:output indent="yes" name="javascript" method="text"/>


  <xsl:template match="*[df:class(., 'map/map')]" mode="generate-dynamic-toc">
    <xsl:param name="index-terms" as="element()" tunnel="yes"/>
    
    <xsl:if test="$generateDynamicTocBoolean">
      
      <xsl:message> + [INFO] Generating dynamic ToC...</xsl:message>
      
      <xsl:apply-templates select="." mode="generate-dynamic-toc-page-markup"/>
      <xsl:apply-templates select="." mode="generate-dynamic-toc-javascript"/>
      
      <xsl:message> + [INFO] Dynamic ToC generation done.</xsl:message>
    </xsl:if>
  </xsl:template>
  
  <xsl:template mode="generate-dynamic-toc-javascript" match="*[df:class(., 'map/map')]">
    <xsl:param name="index-terms" as="element()" tunnel="yes"/>


    <xsl:variable name="pubTitle" as="xs:string*">
      <xsl:apply-templates select="*[df:class(., 'topic/title')] | @title" mode="pubtitle"/>
    </xsl:variable>           
    <xsl:variable name="resultUri" 
      select="relpath:newFile($outdir, 'toc.js')" 
      as="xs:string"/>

    <xsl:message> + [INFO] Generating dynamic ToC file "<xsl:sequence select="$resultUri"/>"...</xsl:message>
    
    <xsl:result-document href="{$resultUri}" method="text">
      // 
      // Javascript generated by HTML2 Toolkit plugin
      // 
      var tree;
      
      function treeInit() {
      tree = new YAHOO.widget.TreeView("treeDiv1");
      var root = tree.getRoot();&#x0a;
      <xsl:apply-templates mode="generate-dynamic-toc" select="*[df:class(., 'map/topicref')]">
        <xsl:with-param name="parentId" select="'root'" as="xs:string" tunnel="yes"/>
        <xsl:with-param name="tocDepth" as="xs:integer" select="0" tunnel="yes"/>
      </xsl:apply-templates>
      <xsl:if test="$generateIndexBoolean">
        <xsl:apply-templates mode="generate-dynamic-toc" select="$index-terms">
          <xsl:with-param name="parentId" select="'root'" as="xs:string" tunnel="yes"/>
        </xsl:apply-templates>
      </xsl:if>
      
      tree.draw(); 
      } 
      
      YAHOO.util.Event.addListener(window, "load", treeInit);       
    </xsl:result-document>  
  </xsl:template>
  
  <xsl:template mode="generate-dynamic-toc-page-markup" match="*[df:class(., 'map/map')]">
    <xsl:param name="index-terms" as="element()" tunnel="yes"/>

    <xsl:message> + [INFO] Generating dynamic ToC HTML markup for root page...</xsl:message>

    <div class="dynamic-toc"><xsl:sequence select="'&#x0a;'"/>
      <div id="container">   <xsl:sequence select="'&#x0a;'"/>       
        <div id="containerTop"><xsl:sequence select="'&#x0a;'"/>
          <div id="main"><xsl:sequence select="'&#x0a;'"/>
            <div id="content"><xsl:sequence select="'&#x0a;'"/>
              <form name="mainForm" action="javscript:;"><xsl:sequence select="'&#x0a;'"/>
                <div class="newsItem"><xsl:sequence select="'&#x0a;'"/>
                  <div id="expandcontractdiv"><xsl:sequence select="'&#x0a;'"/>
                    <a href="javascript:tree.expandAll()">Expand all</a><xsl:sequence select="'&#x0a;'"/>
                    <a href="javascript:tree.collapseAll()">Collapse all</a><xsl:sequence select="'&#x0a;'"/>
                  </div><xsl:sequence select="'&#x0a;'"/>
                  <div id="treeDiv1">&#xa0;</div><xsl:sequence select="'&#x0a;'"/>
                </div><xsl:sequence select="'&#x0a;'"/>
              </form><xsl:sequence select="'&#x0a;'"/>
            </div><xsl:sequence select="'&#x0a;'"/>
          </div><xsl:sequence select="'&#x0a;'"/>
        </div><xsl:sequence select="'&#x0a;'"/>
      </div><xsl:sequence select="'&#x0a;'"/>        
    </div><xsl:sequence select="'&#x0a;'"/>    
  </xsl:template>
  
  <xsl:template mode="generate-dynamic-toc" match="*[df:class(., 'topic/title')]"/>
  
  <!-- Convert each topicref to a ToC entry. -->
  <xsl:template match="*[df:isTopicRef(.)]" mode="generate-dynamic-toc">
    <xsl:param name="tocDepth" as="xs:integer" tunnel="yes" select="0"/>
    <xsl:param name="parentId" as="xs:string"  tunnel="yes"/>
    <xsl:param name="rootMapDocUrl" as="xs:string" tunnel="yes"/>
    
    <xsl:if test="$tocDepth le $maxTocDepthInt">
      <xsl:variable name="navPointTitle">
        <xsl:apply-templates select="." mode="nav-point-title"/>      
      </xsl:variable>
      <xsl:variable name="topic" select="df:resolveTopicRef(.)" as="element()*"/>
      <xsl:choose>
        <xsl:when test="not($topic)">
          <xsl:message> + [WARNING] Failed to resolve topic reference to href "<xsl:sequence select="string(@href)"/>"</xsl:message>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="targetUri" select="htmlutil:getTopicResultUrl($outdir, root($topic), $rootMapDocUrl)" as="xs:string"/>
          <xsl:variable name="relativeUri" select="relpath:getRelativePath($outdir, $targetUri)" as="xs:string"/>
          <xsl:variable name="enumeration" as="xs:string?">
            <xsl:apply-templates select="." mode="enumeration"/>
          </xsl:variable>
          <xsl:variable name="self" select="generate-id(.)" as="xs:string"/>

          <xsl:sequence select="concat('&#x0a;', 'var obj', $self, ' = {')"/>
          <xsl:text>
  label: "</xsl:text>
          <xsl:sequence select="local:escapeStringforJavaScript(
                if ($enumeration = '')
                   then normalize-space($navPointTitle)
                   else concat($enumeration, ' ', $navPointTitle)
                   )"/>
          <xsl:text>",
  href: "</xsl:text>
          <xsl:sequence select="$relativeUri"/>
          <xsl:text>", 
  target:"</xsl:text><xsl:value-of select="$contenttarget"/><xsl:text>"
};
</xsl:text>
          
          <xsl:call-template name="makeJsTextNode">
           <xsl:with-param name="linkObjId" select="$self"/>
            <xsl:with-param name="parentId" select="$parentId" tunnel="yes"/>
          </xsl:call-template>
                   
            <!-- Any subordinate topics in the currently-referenced topic are
              reflected in the ToC before any subordinate topicrefs.
            -->
            <xsl:apply-templates mode="#current" 
              select="$topic/*[df:class(., 'topic/topic')], *[df:class(., 'map/topicref')]">
              <xsl:with-param name="tocDepth" as="xs:integer" tunnel="yes"
                select="$tocDepth + 1"
              />
              <xsl:with-param name="parentId" select="$self" as="xs:string" tunnel="yes"/>
            </xsl:apply-templates>
        </xsl:otherwise>
      </xsl:choose>    
    </xsl:if>    
  </xsl:template>
  
  <xsl:template match="index-terms:index-terms" mode="generate-dynamic-toc">
    <xsl:param name="parentId" as="xs:string" tunnel="yes"/>
    
    <xsl:text>var </xsl:text>
    <xsl:sequence select="generate-id(.)"/>
    <xsl:text> = new YAHOO.widget.TextNode(</xsl:text>
    <xsl:text>"</xsl:text>
    <xsl:text>Index</xsl:text><!-- FIXME: Enable localization -->
    <xsl:text>"</xsl:text>
    <xsl:text>, </xsl:text>
    <xsl:sequence select="$parentId"/>
    <xsl:text>, false);&#x0a;</xsl:text>
    <xsl:apply-templates select="index-terms:index-term | index-terms:index-group" mode="#current">
      <xsl:with-param name="parentId" as="xs:string" tunnel="yes" select="generate-id(.)"/>
    </xsl:apply-templates>
  </xsl:template>  
  
  <xsl:template match="index-terms:index-term[./index-terms:target = ''] | index-terms:index-group" 
    mode="generate-dynamic-toc">
    <xsl:param name="parentId" as="xs:string" tunnel="yes"/>
    <xsl:text>var </xsl:text>
    <xsl:sequence select="generate-id(.)"/>
    <xsl:text> = new YAHOO.widget.TextNode(</xsl:text>
    <xsl:text>"</xsl:text>
    <xsl:apply-templates select="index-terms:label" mode="#current"/>
    <xsl:text>"</xsl:text>
    <xsl:text>, </xsl:text>
    <xsl:sequence select="$parentId"/>
    <xsl:text>, false);&#x0a;</xsl:text>
    <xsl:apply-templates select="index-terms:index-term" mode="#current">
      <xsl:with-param name="parentId" as="xs:string" tunnel="yes" select="generate-id(.)"/>
    </xsl:apply-templates>
    
  </xsl:template>  
  
  <xsl:template match="index-terms:index-term[./index-terms:target != '']" mode="generate-dynamic-toc">
    <xsl:param name="parentId" as="xs:string" tunnel="yes"/>
    
    <xsl:variable name="targetUri" as="xs:string"
      select="string(index-terms:target)"
    />
    
    <xsl:variable name="relativeUri" select="relpath:getRelativePath($outdir, $targetUri)" as="xs:string"/>
    
    <xsl:variable name="self" select="generate-id(.)" as="xs:string"/>
    
    <xsl:sequence select="concat('&#x0a;', 'var obj', $self, ' = {')"/>
    <xsl:text>
    label: "</xsl:text>
    <xsl:apply-templates select="index-terms:label" mode="#current"/>
    <xsl:text>",
  href: "</xsl:text>
    <xsl:sequence select="$relativeUri"/>
    <xsl:text>", 
  target:"</xsl:text><xsl:value-of select="$contenttarget"/><xsl:text>"
};
</xsl:text>
    
    <xsl:call-template name="makeJsTextNode">
      <xsl:with-param name="linkObjId" select="$self"/>
      <xsl:with-param name="parentId" select="$parentId" tunnel="yes"/>
    </xsl:call-template>
    
    <xsl:apply-templates select="index-terms:index-term" mode="#current">
      <xsl:with-param name="parentId" as="xs:string" tunnel="yes" select="generate-id(.)"/>
    </xsl:apply-templates>
  </xsl:template>  
  
  <xsl:template mode="generate-dynamic-toc" match="index-terms:label">
    <xsl:variable name="labelString">
      <xsl:apply-templates mode="dynamic-toc-index-term-label"/>
    </xsl:variable>
    <xsl:sequence select="local:escapeStringforJavaScript($labelString)"/>
  </xsl:template>
  
  
  
  <xsl:template name="makeJsTextNode">
    <xsl:param name="linkObjId" as="xs:string"/>
    <xsl:param name="parentId" as="xs:string"  tunnel="yes"/>
    
    <xsl:text>var </xsl:text>
    <xsl:sequence select="$linkObjId"/>
    <xsl:text> = new YAHOO.widget.TextNode(</xsl:text>
    <xsl:sequence select="concat('obj', $linkObjId)"/>
    <xsl:text>, </xsl:text>
    <xsl:sequence select="$parentId"/>
    <xsl:text>, false);&#x0a;</xsl:text>

  </xsl:template>
  
  <xsl:template mode="nav-point-title" match="*[df:isTopicRef(.)] | *[df:isTopicHead(.)]">
    <xsl:variable name="navPointTitleString" select="df:getNavtitleForTopicref(.)"/>
    <xsl:sequence select="$navPointTitleString"/>    
  </xsl:template>
    
  <xsl:template match="*[df:isTopicGroup(.)]" priority="20" mode="generate-dynamic-toc">
    <xsl:apply-templates select="*[df:class(., 'map/topicref')]" mode="#current"/>
  </xsl:template>
  
  <xsl:template match="*[df:class(., 'topic/topic')]" mode="generate-dynamic-toc">
    <!-- Non-root topics generate ToC entries if they are within the ToC depth -->
    <xsl:param name="tocDepth" as="xs:integer" tunnel="yes" select="0"/>
    <xsl:if test="$tocDepth le $maxTocDepthInt">
      <!-- FIXME: Handle nested topics here. -->
    </xsl:if>
  </xsl:template>
  
  <xsl:template mode="#all" match="*[df:class(., 'map/topicref') and (@processing-role = 'resource-only')]" priority="30"/>


  <!-- topichead elements get a navPoint, but don't actually point to
       anything.  Same with topicref that has no @href. -->
  <xsl:template match="*[df:isTopicHead(.)]" mode="generate-dynamic-toc">
    <xsl:param name="tocDepth" as="xs:integer" tunnel="yes" select="0"/>
    <xsl:param name="parentId" as="xs:string" tunnel="yes"/>
    
    <xsl:if test="$tocDepth le $maxTocDepthInt">
      <xsl:text>var </xsl:text>
      <xsl:sequence select="generate-id(.)"/>
      <xsl:text> = new YAHOO.widget.TextNode(</xsl:text>
      <xsl:text>"</xsl:text>
      <xsl:sequence select="df:getNavtitleForTopicref(.)"/>
      <xsl:text>"</xsl:text>
      <xsl:text>, </xsl:text>
      <xsl:sequence select="$parentId"/>
      <xsl:text>, false);&#x0a;</xsl:text>
      <xsl:apply-templates select="*[df:class(., 'map/topicref')]" mode="#current">
          <xsl:with-param name="tocDepth" as="xs:integer" tunnel="yes"
            select="$tocDepth + 1"
          />        
          <xsl:with-param name="parentId" as="xs:string" tunnel="yes" select="generate-id(.)"/>
      </xsl:apply-templates>
    </xsl:if>
  </xsl:template>

  <xsl:template match="*[df:isTopicGroup(.)]" mode="nav-point-title">
    <!-- Per the 1.2 spec, topic group navtitles are always ignored -->
  </xsl:template>
  
<!--  <xsl:template mode="nav-point-title" match="*[df:class(., 'topic/title')]" priority="10">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
-->  
<!--  WEK: included #default mode, which is bad. -->

  <xsl:template mode="nav-point-title" match="*[df:class(., 'topic/fn')]" priority="10">
    <!-- Suppress footnotes in titles -->
  </xsl:template>
  
  <xsl:template match="*[df:class(., 'topic/tm')]" mode="generate-dynamic-toc nav-point-title"> 
    <xsl:apply-templates mode="#current"/>
    <xsl:choose>
      <xsl:when test="@type = 'reg'">
        <xsl:text>[reg]</xsl:text>
      </xsl:when>
      <xsl:when test="@type = 'sm'">
        <xsl:text>[sm]</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>[tm]</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    
  </xsl:template>
  
  <xsl:template match="
    *[df:class(., 'topic/topicmeta')] | 
    *[df:class(., 'map/navtitle')] | 
    *[df:class(., 'topic/title')] | 
    *[df:class(., 'topic/ph')] |
    *[df:class(., 'topic/cite')] |
    *[df:class(., 'topic/image')] |
    *[df:class(., 'topic/keyword')] |
    *[df:class(., 'topic/term')]
    " mode="generate-dynamic-toc">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <xsl:template match="*[df:class(., 'topic/title')]//text()" mode="generate-dynamic-toc">
    <xsl:copy/>
  </xsl:template>
  
  <xsl:template match="*[df:class(., 'map/map')]" mode="generate-dynamic-toc-script-includes">
    <xsl:if test="$generateDynamicTocBoolean">
      <!-- For dynamic ToC. NOTE: script elements must have both start and end tags. -->
      <script type="text/javascript" src="yahoo.js" >&#xa0;</script><xsl:sequence select="'&#x0a;'"/>
      <script type="text/javascript" src="event.js">&#xa0;</script><xsl:sequence select="'&#x0a;'"/>
      <script type="text/javascript" src="treeview.js" >&#xa0;</script><xsl:sequence select="'&#x0a;'"/>
      <script type="text/javascript" src="toc.js">&#xa0;</script><xsl:sequence select="'&#x0a;'"/>
    </xsl:if>
    
  </xsl:template>
  
  <xsl:template match="text()" mode="generate-dynamic-toc"/>
  
  <xsl:function name="local:isNavPoint" as="xs:boolean">
    <xsl:param name="context" as="element()"/>
    <xsl:choose>
      <xsl:when test="$context/@processing-role = 'resource-only'">
        <xsl:sequence select="false()"/>
      </xsl:when>
      <xsl:when test="df:isTopicRef($context) or df:isTopicHead($context)">
        <xsl:sequence select="true()"/>
      </xsl:when>
      <xsl:when test="df:isTopicGroup($context)">
        <xsl:variable name="navPointTitle" as="xs:string*">
          <xsl:apply-templates select="$context" mode="nav-point-title"/>
        </xsl:variable>
        <!-- If topic head has a title (e.g., a generated title), then it 
             acts as a navigation point.
          -->
        <xsl:sequence
           select="normalize-space(string-join($navPointTitle, ' ')) != ''"
        />
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="false()"/>
      </xsl:otherwise>
    </xsl:choose>
    
  </xsl:function>
  
  <xsl:function name="local:escapeStringforJavaScript" as="xs:string">
    <xsl:param name="s" as="xs:string"/>
    <xsl:sequence
      select="replace(
      replace(
      replace(
      replace($s, &quot;'&quot;, &quot;\\'&quot;),
      '&quot;',
      '\\&quot;'
      ),
      '\r',
      '\\r'
      ),
      '\n',
      '\\n'
      )"/>
  </xsl:function>


</xsl:stylesheet>
