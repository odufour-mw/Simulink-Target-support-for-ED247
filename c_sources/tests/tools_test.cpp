/*
 * Copyright 2020 The MathWorks, Inc.
 */

#include "gtest/gtest.h"

#include "testutils.h"

#include "tools.h"

 TEST(ToolsTest, FileParts)
 {
	/* [ SETUP ] */
	std::string absolutefilename = "C:\\Temp\\projectA\\fileB.txt";
	char folder[STRING_MAX_LENGTH];

	/* [ EXERCISE ] */
	ed247simulink::Tools::fileparts(absolutefilename.c_str(),folder);

	/* [ VERIFY ] */
	EXPECT_STREQ(folder, "C:\\Temp\\projectA");

 }