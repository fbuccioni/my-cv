<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet 
    version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
>
    <xsl:param name="lang" />
    <xsl:variable name="trans__skills" as="xs:string" select="if ($lang = 'es') then 'Habilidades' else 'Skills'" />
    <xsl:variable name="trans__about" as="xs:string" select="if ($lang = 'es') then 'Resumen' else 'About'" />
    <xsl:variable name="trans__links" as="xs:string" select="if ($lang = 'es') then 'Enlaces' else 'Links'" />
    <xsl:variable name="trans__experience" as="xs:string" select="if ($lang = 'es') then 'Experiencia' else 'Experience'" />
    <xsl:variable name="trans__since" as="xs:string" select="if ($lang = 'es') then 'Desde' else 'Since'" />
    <xsl:variable name="trans__until" as="xs:string" select="if ($lang = 'es') then 'hasta' else 'until'" />
    <xsl:variable name="trans__more_jobs" as="xs:string" select="if ($lang = 'es') then 'Más {n} trabajos anteriores, para más información preguntar directamente' else 'And {n} more previous jobs, for more information please ask directly'" />
    <xsl:template name="trans">
        <xsl:choose>
            <xsl:when test="@lang = $lang">
                <xsl:value-of select="@lang" />
            </xsl:when>
            <xsl:when test="trans/@lang = $lang">
                <xsl:value-of select="trans[@lang = $lang]" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="." />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="/">
        <html>
            <head>
                <link rel="stylesheet" href="../src/cv.css" />
            </head>
            <body>
                <header>
                    <h1><xsl:value-of select="cv/@name"/></h1>
                </header>
                <aside>
                    <section>
                        <div class="title">Personal</div>
                        <div class="left-icon-text">
                            <span>📱</span><xsl:value-of select="cv/personal/phone" />
                        </div>
                        <div class="left-icon-text">
                            <span>✉</span><xsl:value-of select="cv/personal/email" />
                        </div>   
                    </section>   
                    <section>
                        <div class="title"><xsl:value-of select="$trans__skills" /></div>
                        <table class="skills" cellpadding="0" cellspacing="0" border="0">
                        <xsl:for-each select="cv/skills/skill">
                            <tr>
                                <td><xsl:value-of select="." /></td>
                                <td class="rate">
                                    <span class="star-solid">
                                    <xsl:for-each select="1 to xs:integer(@rate)">★</xsl:for-each>
                                    </span>
                                    <xsl:if test="xs:integer(@rate) &lt; 5">
                                        <span class="star-hollow">
                                        <xsl:for-each select="1 to (5 - xs:integer(@rate))">★</xsl:for-each>
                                        </span>
                                    </xsl:if>
                                </td>
                            </tr>
                        </xsl:for-each>
                        </table>
                    </section>              
                </aside>
                <content>
                    <section>
                        <div class="title"><xsl:value-of select="$trans__about" /></div>
                        <div>
                            <xsl:for-each select="cv/about">
                                <xsl:call-template name="trans" />
                            </xsl:for-each>
                        </div>
                    </section>
                    <section class="links">
                        <div class="title"><xsl:value-of select="$trans__links" /></div>
                        <table cellpadding="0" cellspaging="0" border="0">
                            <tbody>
                            <xsl:for-each select="cv/links/link">
                                <tr>
                                    <td class="icon">
                                        <img src="../src/icons/{@icon}" />
                                    </td>
                                    <td class="name">
                                        <a href="{@url}">
                                            <xsl:for-each select="name">
                                                <xsl:call-template name="trans" />
                                            </xsl:for-each>
                                        </a>
                                    </td>
                                    <td>
                                        <xsl:for-each select="description">
                                            <xsl:call-template name="trans" />
                                        </xsl:for-each>
                                    </td>
                                </tr>                            
                            </xsl:for-each>
                            </tbody>
                        </table>
                    </section>
                    <section class="experience">
                        <div class="title"><xsl:value-of select="$trans__experience" /></div>
                        <table cellpadding="0" cellspaging="0" border="0">
                            <tbody>
                            <xsl:for-each select="cv/jobs/job">
                                <tr>
                                    <td rowspan="2">
                                        <xsl:for-each select="for">
                                            <xsl:call-template name="trans" />
                                        </xsl:for-each>
                                    </td>
                                    <td>
                                        <xsl:value-of select="$trans__since" />
                                        <xsl:text> </xsl:text>
                                        <xsl:value-of select="@since" />
                                        <xsl:if test="@until">
                                            <xsl:text> </xsl:text>
                                            <xsl:value-of select="$trans__until" />
                                            <xsl:text> </xsl:text>
                                            <xsl:value-of select="@until" />
                                        </xsl:if>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <ul>
                                        <xsl:for-each select="project">
                                            <li>
                                                <xsl:call-template name="trans" /> 
                                                <small>(<xsl:value-of select="@tech" />)</small>
                                            </li>
                                        </xsl:for-each>
                                        </ul>
                                    </td>
                                </tr>
                            </xsl:for-each>
                            </tbody>
                        </table>
                        <xsl:if test="cv/jobs/@more">
                            <div class="more jobs"><xsl:value-of select="replace($trans__more_jobs, '\{n\}', cv/jobs/@more)" />.</div>
                        </xsl:if>
                    </section>
                </content>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>
