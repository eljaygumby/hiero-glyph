<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output method="xml" indent="yes"/>
 
  <xsl:template match="/xml_grep">
      <xsl:apply-templates select="cci_item"/>
  </xsl:template>
 
  <xsl:template match="cci_item">
      <xsl:value-of select="references/reference/@index" />:<xsl:value-of select="type" />/<xsl:value-of select="@id" />:<xsl:value-of select="definition" />XXX
</xsl:template>
 
</xsl:stylesheet>
