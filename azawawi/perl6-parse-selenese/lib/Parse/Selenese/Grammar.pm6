
use v6;

#use Grammar::Tracer;
#use Grammar::Debugger;

unit grammar Parse::Selenese::Grammar;

rule TOP {
  ^
  '<?xml version="1.0" encoding="UTF-8"?>'
  '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">'
  '<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">'
  [<test_case> | <test_suite>]
  '</tbody></table>'
  '</body>'
  '</html>'
  $
}

rule test_case {
  '<head profile="http://selenium-ide.openqa.org/profiles/test-case">'
  '<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />'
  '<link rel="selenium.base" href="' <base_url> '" />'
  <title>
  '</head>'
  '<body>'
  '<table cellpadding="1" cellspacing="1" border="1">'
  '<thead>'
  '<tr><td rowspan="1" colspan="3">' .+? '</td></tr>'
  '</thead><tbody>'
  <commands>
}

rule test_suite {
  '<head>'
  '<meta content="text/html; charset=UTF-8" http-equiv="content-type" />'
  <title>
  '</head>'
  '<body>'
  '<table id="suiteTable" cellpadding="1" cellspacing="1" border="1" class="selenium"><tbody>'
  '<tr><td><b>Test Suite</b></td></tr>'
  <test_case_defs>
}

token title {
  '<title>' $<value>=.+? '</title>'
}

rule test_case_defs {
  <test_case_def>*
}

rule test_case_def {
  '<tr><td><a href="' $<url>=.*? '">' $<name>=.*? '</a></td></tr>'
}

rule commands {
  $<value>=<command>*
}

token base_url {
  $<value>='http://some-server:3000/'
}

rule command {
  '<tr>'
  '<td>' $<name>=<selenium_command> '</td>'
  '<td>' $<target>=.*? '</td>'
  '<td>' $<value>=.*? '</td>'
  '</tr>'
}

token selenium_command {
    <action>
  | <accessor>
  | <assertion>
}

# Actions are commands that generally manipulate the state of the application.
# If an Action fails, or has an error, the execution of the current test
# is stopped.
token action {
    <immediate_action>
  | <waitable_action>
}

token immediate_action {
    'open'
  | 'selectWindow'
  | 'chooseCancelOnNextConfirmation'
  | 'answerOnNextPrompt'
  | 'close'
  | 'setContext'
  | 'setTimeout'
  | 'selectFrame'
}

token waitable_action {
  (   'addLocationStrategy'
    | 'addScript'
    | 'addSelection'
    | 'allowNativeXpath'
    | 'altKeyDown'
    | 'altKeyUp'
    | 'assignId'
    | 'break'
    | 'captureEntirePageScreenshot'
    | 'check'
    | 'chooseOkOnNextConfirmation'
    | 'click'
    | 'clickAt'
    | 'contextMenu'
    | 'contextMenuAt'
    | 'controlKeyDown'
    | 'controlKeyUp'
    | 'createCookie'
    | 'deleteAllVisibleCookies'
    | 'deleteCookie'
    | 'deselectPopUp'
    | 'doubleClick'
    | 'doubleClickAt'
    | 'dragAndDrop'
    | 'dragAndDropToObject'
    | 'dragdrop'
    | 'echo'
    | 'fireEvent'
    | 'focus'
    | 'goBack'
    | 'highlight'
    | 'ignoreAttributesWithoutValue'
    | 'keyDown'
    | 'keyPress'
    | 'keyUp'
    | 'metaKeyDown'
    | 'metaKeyUp'
    | 'mouseDown'
    | 'mouseDownAt'
    | 'mouseDownRight'
    | 'mouseDownRightAt'
    | 'mouseMove'
    | 'mouseMoveAt'
    | 'mouseOut'
    | 'mouseOver'
    | 'mouseUp'
    | 'mouseUpAt'
    | 'mouseUpRight'
    | 'mouseUpRightAt'
    | 'openWindow'
    | 'pause'
    | 'refresh'
    | 'removeAllSelections'
    | 'removeScript'
    | 'removeSelection'
    | 'rollup'
    | 'runScript'
    | 'select'
    | 'selectPopUp'
    | 'setBrowserLogLevel'
    | 'setCursorPosition'
    | 'setMouseSpeed'
    | 'setSpeed'
    | 'shiftKeyDown'
    | 'shiftKeyUp'
    | 'store'
    | 'submit'
    | 'type'
    | 'typeKeys'
    | 'uncheck'
    | 'useXpathLibrary'
    | 'waitForCondition'
    | 'waitForFrameToLoad'
    | 'waitForPageToLoad'
    | 'waitForPopUp'
    | 'windowFocus'
    | 'windowMaximize' ) 'AndWait'?
}

# Commands that examine the state of the application and store the results
# in variables
token accessor {
    'assertErrorOnNext'
  | 'assertFailureOnNext'
  | 'assertSelected'
  | 'storeAlert'
  | 'storeAllButtons'
  | 'storeAllFields'
  | 'storeAllLinks'
  | 'storeAllWindowIds'
  | 'storeAllWindowNames'
  | 'storeAllWindowTitles'
  | 'storeAttribute'
  | 'storeAttributeFromAllWindows'
  | 'storeBodyText'
  | 'storeConfirmation'
  | 'storeCookie'
  | 'storeCookieByName'
  | 'storeCursorPosition'
  | 'storeElementHeight'
  | 'storeElementIndex'
  | 'storeElementPositionLeft'
  | 'storeElementPositionTop'
  | 'storeElementWidth'
  | 'storeEval'
  | 'storeExpression'
  | 'storeHtmlSource'
  | 'storeLocation'
  | 'storeMouseSpeed'
  | 'storePrompt'
  | 'storeSelectedId'
  | 'storeSelectedIds'
  | 'storeSelectedIndex'
  | 'storeSelectedIndexes'
  | 'storeSelectedLabel'
  | 'storeSelectedLabels'
  | 'storeSelectedValue'
  | 'storeSelectedValues'
  | 'storeSelectOptions'
  | 'storeSpeed'
  | 'storeTable'
  | 'storeText'
  | 'storeTitle'
  | 'storeValue'
  | 'storeWhetherThisFrameMatchFrameExpression'
  | 'storeWhetherThisWindowMatchWindowExpression'
  | 'storeXpathCount'
  | 'storeAlertPresent'
  | 'storeChecked'
  | 'storeConfirmationPresent'
  | 'storeCookiePresent'
  | 'storeEditable'
  | 'storeElementPresent'
  | 'storeOrdered'
  | 'storePromptPresent'
  | 'storeSomethingSelected'
  | 'storeTextPresent'
  | 'storeVisible'
}

# Command that are like Accessors but they verify that the state of the
# application conforms to what is expected
token assertion {
    'assertNotErrorOnNext'
  | 'verifyErrorOnNext'
  | 'verifyNotErrorOnNext'
  | 'waitForErrorOnNext'
  | 'waitForNotErrorOnNext'
  | 'assertNotFailureOnNext'
  | 'verifyFailureOnNext'
  | 'verifyNotFailureOnNext'
  | 'waitForFailureOnNext'
  | 'waitForNotFailureOnNext'
  | 'assertNotSelected'
  | 'verifySelected'
  | 'verifyNotSelected'
  | 'waitForSelected'
  | 'waitForNotSelected'
  | 'assertAlert'
  | 'assertNotAlert'
  | 'verifyAlert'
  | 'verifyNotAlert'
  | 'waitForAlert'
  | 'waitForNotAlert'
  | 'assertAllButtons'
  | 'assertNotAllButtons'
  | 'verifyAllButtons'
  | 'verifyNotAllButtons'
  | 'waitForAllButtons'
  | 'waitForNotAllButtons'
  | 'assertAllFields'
  | 'assertNotAllFields'
  | 'verifyAllFields'
  | 'verifyNotAllFields'
  | 'waitForAllFields'
  | 'waitForNotAllFields'
  | 'assertAllLinks'
  | 'assertNotAllLinks'
  | 'verifyAllLinks'
  | 'verifyNotAllLinks'
  | 'waitForAllLinks'
  | 'waitForNotAllLinks'
  | 'assertAllWindowIds'
  | 'assertNotAllWindowIds'
  | 'verifyAllWindowIds'
  | 'verifyNotAllWindowIds'
  | 'waitForAllWindowIds'
  | 'waitForNotAllWindowIds'
  | 'assertAllWindowNames'
  | 'assertNotAllWindowNames'
  | 'verifyAllWindowNames'
  | 'verifyNotAllWindowNames'
  | 'waitForAllWindowNames'
  | 'waitForNotAllWindowNames'
  | 'assertAllWindowTitles'
  | 'assertNotAllWindowTitles'
  | 'verifyAllWindowTitles'
  | 'verifyNotAllWindowTitles'
  | 'waitForAllWindowTitles'
  | 'waitForNotAllWindowTitles'
  | 'assertAttribute'
  | 'assertNotAttribute'
  | 'verifyAttribute'
  | 'verifyNotAttribute'
  | 'waitForAttribute'
  | 'waitForNotAttribute'
  | 'assertAttributeFromAllWindows'
  | 'assertNotAttributeFromAllWindows'
  | 'verifyAttributeFromAllWindows'
  | 'verifyNotAttributeFromAllWindows'
  | 'waitForAttributeFromAllWindows'
  | 'waitForNotAttributeFromAllWindows'
  | 'assertBodyText'
  | 'assertNotBodyText'
  | 'verifyBodyText'
  | 'verifyNotBodyText'
  | 'waitForBodyText'
  | 'waitForNotBodyText'
  | 'assertConfirmation'
  | 'assertNotConfirmation'
  | 'verifyConfirmation'
  | 'verifyNotConfirmation'
  | 'waitForConfirmation'
  | 'waitForNotConfirmation'
  | 'assertCookie'
  | 'assertNotCookie'
  | 'verifyCookie'
  | 'verifyNotCookie'
  | 'waitForCookie'
  | 'waitForNotCookie'
  | 'assertCookieByName'
  | 'assertNotCookieByName'
  | 'verifyCookieByName'
  | 'verifyNotCookieByName'
  | 'waitForCookieByName'
  | 'waitForNotCookieByName'
  | 'assertCursorPosition'
  | 'assertNotCursorPosition'
  | 'verifyCursorPosition'
  | 'verifyNotCursorPosition'
  | 'waitForCursorPosition'
  | 'waitForNotCursorPosition'
  | 'assertElementHeight'
  | 'assertNotElementHeight'
  | 'verifyElementHeight'
  | 'verifyNotElementHeight'
  | 'waitForElementHeight'
  | 'waitForNotElementHeight'
  | 'assertElementIndex'
  | 'assertNotElementIndex'
  | 'verifyElementIndex'
  | 'verifyNotElementIndex'
  | 'waitForElementIndex'
  | 'waitForNotElementIndex'
  | 'assertElementPositionLeft'
  | 'assertNotElementPositionLeft'
  | 'verifyElementPositionLeft'
  | 'verifyNotElementPositionLeft'
  | 'waitForElementPositionLeft'
  | 'waitForNotElementPositionLeft'
  | 'assertElementPositionTop'
  | 'assertNotElementPositionTop'
  | 'verifyElementPositionTop'
  | 'verifyNotElementPositionTop'
  | 'waitForElementPositionTop'
  | 'waitForNotElementPositionTop'
  | 'assertElementWidth'
  | 'assertNotElementWidth'
  | 'verifyElementWidth'
  | 'verifyNotElementWidth'
  | 'waitForElementWidth'
  | 'waitForNotElementWidth'
  | 'assertEval'
  | 'assertNotEval'
  | 'verifyEval'
  | 'verifyNotEval'
  | 'waitForEval'
  | 'waitForNotEval'
  | 'assertExpression'
  | 'assertNotExpression'
  | 'verifyExpression'
  | 'verifyNotExpression'
  | 'waitForExpression'
  | 'waitForNotExpression'
  | 'assertHtmlSource'
  | 'assertNotHtmlSource'
  | 'verifyHtmlSource'
  | 'verifyNotHtmlSource'
  | 'waitForHtmlSource'
  | 'waitForNotHtmlSource'
  | 'assertLocation'
  | 'assertNotLocation'
  | 'verifyLocation'
  | 'verifyNotLocation'
  | 'waitForLocation'
  | 'waitForNotLocation'
  | 'assertMouseSpeed'
  | 'assertNotMouseSpeed'
  | 'verifyMouseSpeed'
  | 'verifyNotMouseSpeed'
  | 'waitForMouseSpeed'
  | 'waitForNotMouseSpeed'
  | 'assertPrompt'
  | 'assertNotPrompt'
  | 'verifyPrompt'
  | 'verifyNotPrompt'
  | 'waitForPrompt'
  | 'waitForNotPrompt'
  | 'assertSelectedId'
  | 'assertNotSelectedId'
  | 'verifySelectedId'
  | 'verifyNotSelectedId'
  | 'waitForSelectedId'
  | 'waitForNotSelectedId'
  | 'assertSelectedIds'
  | 'assertNotSelectedIds'
  | 'verifySelectedIds'
  | 'verifyNotSelectedIds'
  | 'waitForSelectedIds'
  | 'waitForNotSelectedIds'
  | 'assertSelectedIndex'
  | 'assertNotSelectedIndex'
  | 'verifySelectedIndex'
  | 'verifyNotSelectedIndex'
  | 'waitForSelectedIndex'
  | 'waitForNotSelectedIndex'
  | 'assertSelectedIndexes'
  | 'assertNotSelectedIndexes'
  | 'verifySelectedIndexes'
  | 'verifyNotSelectedIndexes'
  | 'waitForSelectedIndexes'
  | 'waitForNotSelectedIndexes'
  | 'assertSelectedLabel'
  | 'assertNotSelectedLabel'
  | 'verifySelectedLabel'
  | 'verifyNotSelectedLabel'
  | 'waitForSelectedLabel'
  | 'waitForNotSelectedLabel'
  | 'assertSelectedLabels'
  | 'assertNotSelectedLabels'
  | 'verifySelectedLabels'
  | 'verifyNotSelectedLabels'
  | 'waitForSelectedLabels'
  | 'waitForNotSelectedLabels'
  | 'assertSelectedValue'
  | 'assertNotSelectedValue'
  | 'verifySelectedValue'
  | 'verifyNotSelectedValue'
  | 'waitForSelectedValue'
  | 'waitForNotSelectedValue'
  | 'assertSelectedValues'
  | 'assertNotSelectedValues'
  | 'verifySelectedValues'
  | 'verifyNotSelectedValues'
  | 'waitForSelectedValues'
  | 'waitForNotSelectedValues'
  | 'assertSelectOptions'
  | 'assertNotSelectOptions'
  | 'verifySelectOptions'
  | 'verifyNotSelectOptions'
  | 'waitForSelectOptions'
  | 'waitForNotSelectOptions'
  | 'assertSpeed'
  | 'assertNotSpeed'
  | 'verifySpeed'
  | 'verifyNotSpeed'
  | 'waitForSpeed'
  | 'waitForNotSpeed'
  | 'assertTable'
  | 'assertNotTable'
  | 'verifyTable'
  | 'verifyNotTable'
  | 'waitForTable'
  | 'waitForNotTable'
  | 'assertText'
  | 'assertNotText'
  | 'verifyText'
  | 'verifyNotText'
  | 'waitForText'
  | 'waitForNotText'
  | 'assertTitle'
  | 'assertNotTitle'
  | 'verifyTitle'
  | 'verifyNotTitle'
  | 'waitForTitle'
  | 'waitForNotTitle'
  | 'assertValue'
  | 'assertNotValue'
  | 'verifyValue'
  | 'verifyNotValue'
  | 'waitForValue'
  | 'waitForNotValue'
  | 'assertWhetherThisFrameMatchFrameExpression'
  | 'assertNotWhetherThisFrameMatchFrameExpression'
  | 'verifyWhetherThisFrameMatchFrameExpression'
  | 'verifyNotWhetherThisFrameMatchFrameExpression'
  | 'waitForWhetherThisFrameMatchFrameExpression'
  | 'waitForNotWhetherThisFrameMatchFrameExpression'
  | 'assertWhetherThisWindowMatchWindowExpression'
  | 'assertNotWhetherThisWindowMatchWindowExpression'
  | 'verifyWhetherThisWindowMatchWindowExpression'
  | 'verifyNotWhetherThisWindowMatchWindowExpression'
  | 'waitForWhetherThisWindowMatchWindowExpression'
  | 'waitForNotWhetherThisWindowMatchWindowExpression'
  | 'assertXpathCount'
  | 'assertNotXpathCount'
  | 'verifyXpathCount'
  | 'verifyNotXpathCount'
  | 'waitForXpathCount'
  | 'waitForNotXpathCount'
  | 'assertAlertPresent'
  | 'assertAlertNotPresent'
  | 'verifyAlertPresent'
  | 'verifyAlertNotPresent'
  | 'waitForAlertPresent'
  | 'waitForAlertNotPresent'
  | 'assertChecked'
  | 'assertNotChecked'
  | 'verifyChecked'
  | 'verifyNotChecked'
  | 'waitForChecked'
  | 'waitForNotChecked'
  | 'assertConfirmationPresent'
  | 'assertConfirmationNotPresent'
  | 'verifyConfirmationPresent'
  | 'verifyConfirmationNotPresent'
  | 'waitForConfirmationPresent'
  | 'waitForConfirmationNotPresent'
  | 'assertCookiePresent'
  | 'assertCookieNotPresent'
  | 'verifyCookiePresent'
  | 'verifyCookieNotPresent'
  | 'waitForCookiePresent'
  | 'waitForCookieNotPresent'
  | 'assertEditable'
  | 'assertNotEditable'
  | 'verifyEditable'
  | 'verifyNotEditable'
  | 'waitForEditable'
  | 'waitForNotEditable'
  | 'assertElementPresent'
  | 'assertElementNotPresent'
  | 'verifyElementPresent'
  | 'verifyElementNotPresent'
  | 'waitForElementPresent'
  | 'waitForElementNotPresent'
  | 'assertOrdered'
  | 'assertNotOrdered'
  | 'verifyOrdered'
  | 'verifyNotOrdered'
  | 'waitForOrdered'
  | 'waitForNotOrdered'
  | 'assertPromptPresent'
  | 'assertPromptNotPresent'
  | 'verifyPromptPresent'
  | 'verifyPromptNotPresent'
  | 'waitForPromptPresent'
  | 'waitForPromptNotPresent'
  | 'assertSomethingSelected'
  | 'assertNotSomethingSelected'
  | 'verifySomethingSelected'
  | 'verifyNotSomethingSelected'
  | 'waitForSomethingSelected'
  | 'waitForNotSomethingSelected'
  | 'assertTextPresent'
  | 'assertTextNotPresent'
  | 'verifyTextPresent'
  | 'verifyTextNotPresent'
  | 'waitForTextPresent'
  | 'waitForTextNotPresent'
  | 'assertVisible'
  | 'assertNotVisible'
  | 'verifyVisible'
  | 'verifyNotVisible'
  | 'waitForVisible'
  | 'waitForNotVisible'
}
