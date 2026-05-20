<?xml version="1.0" encoding="utf-8" ?>
<%@ page language="java" contentType="text/html; charset=utf-8"
    pageEncoding="utf-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
  <meta content="Copyright (c) 2008-2008 IBM Corporation and others. All Rights Reserved." name="COPYRIGHT" />
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<%@ include file="demohead.jsf" %>
<title>ICU4J Web Demos</title>
<style>
  dl.demos_toc dt { margin: 1em; font-weight: bold; }
</style>
</head>
<body>

<%@ include file="demolist.jsf"  %>

<h2>ICU4J Web Demos</h2>

<p>Here are <%= demolist_new.length %> demos that show different capabilities of the ICU library:</p>

<div>
<dl class="demos_toc">
  <% for (Demo demo : demolist_new) { %>
    <dt><a href="<%= demo.file %>.jsp"><%= demo.name %></a></dt>
    <dd><%= demo.description %></dd>
  <% } %>
</dl>
</div>

<hr/>
Welcome to ICU4J <%= com.ibm.icu.util.VersionInfo.ICU_VERSION %>

</body>
</html>