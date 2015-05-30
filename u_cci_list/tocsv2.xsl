<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output method="xml" indent="yes"/>
 
  <xsl:template match="/xml_grep">
    <root>
      <xsl:apply-templates select="cci_item"/>
    </root>
  </xsl:template>
 
  <xsl:template match="cci_item">
    <name CCI="{@id}" index="{references/reference/@index}">
      <xsl:value-of select="definition" />
    </name>
  </xsl:template>
 
</xsl:stylesheet>
