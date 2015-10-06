--
--  AppDelegate.applescript
--  Advanced User Account Creator
--
--  Created by Thomas Jones on 16/05/2014.
--  Copyright (c) 2014 TomTec Solutions. All rights reserved.
--

script AppDelegate
	property parent : class "NSObject"
	
	property uuidTextField : missing value
	property userNameTextField : missing value
	property fullNameTextField : missing value
	property userShellComboBox : missing value
	property userIDTextField : missing value
	property groupIDTextField : missing value
	property isAdminCheckBox : missing value
	property homeDirectoryTextField : missing value
	property genHomeDirCheckBox : missing value
	property chooseButton : missing value
	property makeAccountButton : missing value
	property passwordTextField : missing value
	property genButton : missing value
	property progress : missing value
	property progressLabel : missing value
	property genUID : missing value
	
	property warningArrowUserTypeSelector : missing value
	property warningArrowUserNameField : missing value
	property warningArrowFullNameField : missing value
	property warningArrowPasswordField : missing value
	property warningArrowUserShellBox : missing value
	property warningArrowUIDField : missing value
	property warningArrowGIDField : missing value
	property warningArrowUUIDField : missing value
	property warningArrowHomeDirField : missing value
	
	property pathToResources : ""
	property userName : ""
	property userShell : ""
	property realName : ""
	property userID : ""
	property groupID : ""
	property homeDirectory : ""
	property uuIdentifier : ""
	property typeOfAccount : ""
	property isAdmin : ""
	property generateHomeDir : ""
	property title : ""
	property nextUID : ""
	property passed : ""
	property thePassword : ""
	property emptyFields : ""
	
	property nonAllowableCharacters : {0, 32, 34, 36, 38, 39, 129}
	
	on tritone()
		try
			do shell script "afplay \"" & pathToResources & "/TriTone.mp3\" &"
		end try
	end tritone
	on makeAccount:sender
		tell progress to startAnimation:me
		setVariables()
		doCheck()
		delay 1
		if passed is 1 then
			updateProgress("Obtaining administrator privileges...")
			try
				do shell script "" with administrator privileges
			on error errorstring
            display dialog errorstring
				updateProgress("A error occurred whilst obtaining appropriate privileves.")
				set passed to 0
			end try
		end if
		if passed is 1 then
			
			if typeOfAccount is "User Account" then
				updateProgress("Creating local account record for '" & userName & "'...")
				do shell script "dscl . create /Users/" & userName with administrator privileges
				updateProgress("Setting user shell to '" & userShell & "'...")
				do shell script "dscl . create /Users/" & userName & " UserShell \"" & userShell & "\"" with administrator privileges
				updateProgress("Setting full name to '" & realName & "'...")
				do shell script "dscl . create /Users/" & userName & " UserShell \"" & userShell & "\"" with administrator privileges
				updateProgress("Setting user ID to " & userID & "...")
				do shell script "dscl . create /Users/" & userName & " UniqueID " & userID with administrator privileges
				updateProgress("Setting group ID to " & groupID & "...")
				do shell script "dscl . create /Users/" & userName & " PrimaryGroupID " & groupID with administrator privileges
				updateProgress("Setting home directory...")
				do shell script "dscl . create /Users/" & userName & " NFSHomeDirectory \"" & homeDirectory & "" & userName & "\"" with administrator privileges
				updateProgress("Setting UUID to " & uuIdentifier & "...")
				do shell script "dscl . create /Users/" & userName & " GeneratedUID " & uuIdentifier with administrator privileges
				updateProgress("Setting record type to dsRecTypeStandard:Users...")
				do shell script "dscl . create /Users/" & userName & " RecordType dsRecTypeStandard:Users" with administrator privileges
				updateProgress("Setting AppleMetaNodeLocation to /Local/Default...")
				do shell script "dscl . create /Users/" & userName & " AppleMetaNodeLocation /Local/Default" with administrator privileges
				if isAdmin is "1" then
					updateProgress("Making the user an administrator...")
					do shell script "dscl . append /Groups/admin GroupMembership " & userName with administrator privileges
					do shell script "dscl . append /Groups/_lpadmin GroupMembership " & userName with administrator privileges
					do shell script "dscl . append /Groups/_appserveradm GroupMembership " & userName with administrator privileges
					do shell script "dscl . append /Groups/_appserverusr GroupMembership " & userName with administrator privileges
				end if
				if generateHomeDir is "1" then
					updateProgress("Creating home directory...")
					do shell script "createhomedir -c -u " & userName with administrator privileges
				end if
			end if
			if typeOfAccount is "Sharing Only" then
				updateProgress("Creating sharing account...")
				do shell script "dscl . create /Users/" & userName with administrator privileges
				do shell script "dscl . create /Users/" & userName & " RealName \"" & realName & "\"" with administrator privileges
				do shell script "dscl . create /Users/" & userName & " UniqueID " & userID with administrator privileges
				do shell script "dscl . create /Users/" & userName & " PrimaryGroupID " & groupID with administrator privileges
				do shell script "dscl . create /Users/" & userName & " NFSHomeDirectory /dev/null" with administrator privileges
				do shell script "dscl . create /Users/" & userName & " GeneratedUID " & uuIdentifier with administrator privileges
				do shell script "dscl . create /Users/" & userName & " RecordType dsRecTypeStandard:Users" with administrator privileges
				do shell script "dscl . create /Users/" & userName & " UserShell /usr/bin/false" with administrator privileges
			end if
		end if
		tell progress to stopAnimation:me
		if passed is 0 then
			updateProgress("Process Halted.")
		else
			tritone()
			updateProgress("Completed creating account '" & userName & "'")
		end if
	end makeAccount:
	
	on updateProgress(labelText)
		tell progressLabel to setStringValue:labelText
		delay 0.2
	end updateProgress
	
	on setVariables()
		set userName to stringValue() of userNameTextField as string
		set userShell to stringValue() of userShellComboBox as string
		set realName to stringValue() of fullNameTextField as string
		set userID to stringValue() of userIDTextField as string
		set groupID to stringValue() of groupIDTextField as string
		set homeDirectory to stringValue() of homeDirectoryTextField as string
		set uuIdentifier to stringValue() of uuidTextField as string
		set isAdmin to state of isAdminCheckBox as string
		set generateHomeDir to state of genHomeDirCheckBox as string
		set thePassword to stringValue() of passwordTextField as string
	end setVariables
	
	on getLatestUID:sender
		getNextUID()
		tell userIDTextField to setStringValue:(nextUID as string)
	end getLatestUID:
	
	on getNextUID()
		set nextUID to (do shell script "dscl . -list /Users UniqueID | awk '{print $2}' | sort -ug | tail -1")
		set nextUID to (nextUID + 1)
	end getNextUID
	
	on sharingAccount:sender
		set typeOfAccount to "Sharing Only"
		tell warningArrowUserTypeSelector to setHidden:1
		tell userNameTextField to setEnabled:1
		tell warningArrowUserNameField to setHidden:0
		tell fullNameTextField to setEnabled:1
		tell warningArrowFullNameField to setHidden:0
		tell passwordTextField to setEnabled:1
		tell warningArrowPasswordField to setHidden:0
		tell userShellComboBox to setEnabled:1
		tell groupIDTextField to setEnabled:1
		tell genUID to setEnabled:1
		tell userIDTextField to setEnabled:1
		tell warningArrowUIDField to setHidden:0
		tell uuidTextField to setEnabled:1
		tell warningArrowUUIDField to setHidden:0
		tell genButton to setEnabled:1
		tell makeAccountButton to setEnabled:1
		tell isAdminCheckBox to setState:0
		tell isAdminCheckBox to setEnabled:0
		tell genHomeDirCheckBox to setState:0
		tell genHomeDirCheckBox to setEnabled:0
		tell homeDirectoryTextField to setEnabled:0
		tell chooseButton to setEnabled:0
		tell userShellComboBox to setEnabled:0
		tell makeAccountButton to setEnabled:1
		tell userShellComboBox to setStringValue:"/usr/bin/false"
	end sharingAccount:
	
	on userAccount:sender
		set typeOfAccount to "User Account"
		tell warningArrowUserTypeSelector to setHidden:1
		tell isAdminCheckBox to setEnabled:1
		tell genHomeDirCheckBox to setEnabled:1
		tell homeDirectoryTextField to setEnabled:1
		tell warningArrowHomeDirField to setHidden:0
		tell genUID to setEnabled:1
		tell chooseButton to setEnabled:1
		tell userShellComboBox to setEnabled:1
		tell warningArrowUserShellBox to setHidden:0
		tell makeAccountButton to setEnabled:1
		tell userNameTextField to setEnabled:1
		tell warningArrowUserNameField to setHidden:0
		tell fullNameTextField to setEnabled:1
		tell warningArrowFullNameField to setHidden:0
		tell passwordTextField to setEnabled:1
		tell warningArrowPasswordField to setHidden:0
		tell groupIDTextField to setEnabled:1
		tell warningArrowGIDField to setHidden:0
		tell userIDTextField to setEnabled:1
		tell warningArrowUIDField to setHidden:0
		tell uuidTextField to setEnabled:1
		tell warningArrowUUIDField to setHidden:0
		tell genButton to setEnabled:1
		tell makeAccountButton to setEnabled:1
		tell isAdminCheckBox to setEnabled:1
		tell genHomeDirCheckBox to setEnabled:1
		tell userShellComboBox to setStringValue:"/bin/bash"
	end userAccount:
	
	on chooseHomeDirectory:sender
		set homeDirectory to the POSIX path of (choose folder with prompt "Select a home directory:" default location "/Users")
		tell homeDirectoryTextField to setStringValue:homeDirectory
	end chooseHomeDirectory:
	
	on doCheck()
		set emptyFields to ""
		set passed to 1
		set x to 1
		set rTimes to number of items in nonAllowableCharacters
		set offendingCharacter to ""
		repeat rTimes times
			if userName contains (ASCII character (item x of nonAllowableCharacters)) then
				set passed to 0
				if (ASCII character (item x of nonAllowableCharacters)) is " " then
					set offendingCharacter to offendingCharacter & "space(s), "
				else
					set offendingCharacter to offendingCharacter & (ASCII character (item x of nonAllowableCharacters)) & ", "
				end if
			end if
			set x to x + 1
		end repeat
		if passed is 0 then
			display alert title message "You have used illegal character(s) in your user name. Please remove these characters." & return & return & "Illegal Character(s) Detected: " & return & offendingCharacter as critical
		end if
		if passed is 1 then
			checkIfUsernameExists()
			checkIfUUIDisCorrect()
		end if
		if passed is 1 then
			checkNotBlank(userName, "User Name")
			checkNotBlank(thePassword, "Password")
			checkNotBlank(realName, "Full Name")
			checkNotBlank(userShell, "User Shell")
			checkNotBlank("display", "display")
		end if
	end doCheck
	
	to checkNotBlank(variableEntered, description)
		if variableEntered is "display" then
			if passed is 0 then
				display alert title message "The following field(s) don't contain anything. They need to be filled in before " & title & " can continue." & return & return & emptyFields
			end if
		end if
		if variableEntered is "" then
			set emptyFields to emptyFields & "¥" & space & description & return
			set passed to 0
		end if
	end checkNotBlank
	
	to checkIfUsernameExists()
		try
			set userList to do shell script "dscl . -list /Users | grep " & userName
		on error
			set userList to ""
		end try
		if userList contains userName then
			display alert title message "Username '" & userName & "' already exists in the local user directory. Please choose another username or delete existing user '" & userName & "'"
			set passed to 0
		end if
	end checkIfUsernameExists
	
	on checkIfUUIDisCorrect()
		set wc to count characters in uuIdentifier
		if wc does not contain 36 then
			tell warningArrowUUIDField to setHidden:0
			display alert title message "The UUID entered was not valid. Please re-enter the UUID, or press Generate."
			set passed to 0
		end if
	end checkIfUUIDisCorrect
	
	on generateUUID:sender
		genUUID()
		tell warningArrowUUIDField to setHidden:1
	end generateUUID:
	
	on genUUID()
		set uuid to (do shell script "uuidgen")
		tell uuidTextField to setStringValue:uuid
		return uuid
	end genUUID
	
	on applicationWillFinishLaunching:aNotification
		set pathToResources to current application's NSBundle's mainBundle()'s resourcePath() as string
		set title to name of current application
		--genUUID()
		--getNextUID()
		try
			tell userIDTextField to setStringValue:(nextUID as string)
		end try
	end applicationWillFinishLaunching:
	
	on applicationShouldTerminate:sender
		-- Insert code here to do any housekeeping before your application quits 
		return current application's NSTerminateNow
	end applicationShouldTerminate:
	
end script