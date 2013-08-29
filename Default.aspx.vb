Imports System.Data
Imports System.Data.SqlClient

Partial Class _Default
    Inherits System.Web.UI.Page

    'Words in database found at http://worksheets.theteacherscorner.net/make-your-own/word-search/ 
    'Game based on http://www.4guysfromrolla.com/articles/121102-1.aspx

    Dim oConn As New SqlConnection(ConfigurationManager.ConnectionStrings.Item("HangmanConnectionString").ConnectionString)
    Dim oCmd As New SqlCommand
    Dim oDA As New SqlDataAdapter
    Dim odTbl As New DataTable
    Dim strSQL As String = ""
    Dim oParam As New SqlParameter

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If IsPostBack Then
            configLetterButtons(False)
        Else
            'In case the browser was closed without quitting
            Session.Clear()
        End If
    End Sub

    Private Sub configLetterButtons(ByVal isNew As Boolean)
        For i As Int16 = Convert.ToInt16("A"c) To Convert.ToInt16("Z"c)
            Dim letter As Char = Convert.ToChar(i)
            Dim btn As Button = CType(board_pnl.FindControl(letter & "_btn"), Button)
            ScriptManager.GetCurrent(Page).RegisterAsyncPostBackControl(btn)

            If isNew Then
                btn.Enabled = True
                btn.CssClass = "LetterButtonStyle"

                solve_btn.Enabled = True
                solve_btn.CssClass = "BigButtonStyle"
                solve_txt.Enabled = True
                solve_txt.Text = ""

            End If
        Next
    End Sub

    'Other approach
    'Private Sub configHangmanImage(ByVal won As Boolean)
    '    For i As Integer = 0 To 6
    '        CType(FindControl("hangman_img" & i), Image).Visible = IIf(won, False, (Session("WrongGuesses") = i))
    '    Next
    '    hangman_img7.Visible = won

    'End Sub

    Protected Sub prepareBoard(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim initialGuess As String = ""

        board_pnl.Visible = True
        options_pnl.Visible = False
        status_pnl.Visible = True

        hangman_img.ImageUrl = "images/hangman0.png"

        Session("HangmanWord") = randomWord()



        'All empty to start out
        For i As Integer = 0 To Session("HangmanWord").ToString().Length - 1
            If Session("HangmanWord").ToString.Substring(i, 1) = " " Then
                initialGuess &= " "
            Else
                initialGuess &= "*"
            End If

        Next

        Session("CurrentWordState") = initialGuess
        Session("WrongGuesses") = 0
        Session("Topic") = topic_ddl.SelectedItem.Text

        topic_lit.Text = "Topic: <b>" & Session("Topic") & "</b>"
        status_lit.Text = "<i>Select letters to guess the word.</i>"

        configWordState(False)
        configLetterButtons(True)

    End Sub

    Private Function randomWord() As String

        Dim rand As New Random()
        Dim selectedWord As String = ""
        Try
            oCmd.Connection = oConn
            oCmd.CommandType = CommandType.Text

            strSQL = "SELECT Word from Words WHERE TopicID = @TopicID"

            oParam = New SqlParameter()
            oParam.ParameterName = "TopicID"
            oParam.SqlDbType = SqlDbType.Int
            oParam.Value = topic_ddl.SelectedValue
            oCmd.Parameters.Add(oParam)

            oCmd.CommandText = strSQL

            oDA.SelectCommand = oCmd
            oDA.Fill(odTbl)

            selectedWord = odTbl.Rows(rand.Next(0, odTbl.Rows.Count))("Word")
            Return selectedWord

        Catch ex As Exception
            Throw ex
        End Try

    End Function

    Protected Sub letterCommand(ByVal sender As Object, ByVal e As CommandEventArgs)
        configLetterButtons(False)

        Dim clickedBtn As Button = CType(sender, Button)
        Dim currentWord As String = ""
        Dim innerStr As String = ""
        clickedBtn.Enabled = False
        clickedBtn.CssClass = "DisabledLetterButtonStyle"

        'If the chosen letter is in the word, update CurrentWordState with the correct letter in the appropriate index
        'currentWord is just used to rebuild the word
        If Session("HangmanWord").ToString.ToLower().IndexOf(e.CommandArgument.ToLower()) >= 0 Then

            For i As Integer = 0 To Session("HangmanWord").ToString().Length - 1
                If Session("HangmanWord").ToString.Substring(i, 1).ToLower() = e.CommandArgument.ToLower() Then
                    currentWord &= Session("HangmanWord").ToString().Substring(i, 1)
                Else
                    currentWord &= Session("CurrentWordState").ToString().Substring(i, 1)
                End If
            Next

            Session("CurrentWordState") = currentWord
            configWordState(False)

            'If the correct letter completed the phrase
            If Session("HangmanWord") = Session("CurrentWordState") Then
                innerStr = "<span class='SuccessStyle'>You completed the phrase before being hanged!</span>"
                endGame(True)
            Else
                innerStr = "<span class='SuccessStyle'><i>Correct letter chosen!</i></span>"
            End If

            'If a wrong letter is chosen, update the hangman image and increment the wrong guesses
        Else

            Session("WrongGuesses") += 1
            hangman_img.ImageUrl = "images/hangman" & Session("WrongGuesses") & ".png"

            If Session("WrongGuesses") >= 6 Then
                innerStr = "<span class='FailStyle'>You didn't complete the phrase. You are now dead.</span>"
                endGame(False)
            Else
                innerStr = "<span class='FailStyle'><i>Uh oh. Incorrect letter.</i></span>"
            End If

        End If

        status_lit.Text = innerStr
        optionsStatus_updatePnl.Update()

    End Sub

    Protected Sub solveClick(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim innerStr As String = ""

        If solve_txt.Text.Trim.ToLower() = Session("HangmanWord") Then
            Session("CurrentWordState") = solve_txt.Text.Trim.ToLower()
            innerStr = "<span class='SuccessStyle'>You guessed the correct phrase! You will live!</span>"
            endGame(True)
        Else
            innerStr = "<span class='FailStyle'>Your guess was incorrect. You are now dead</span>"
            endGame(False)
        End If

        configWordState(True)
        status_lit.Text = innerStr
    End Sub

    'After updating currentWordState 
    Private Sub configWordState(ByVal forEnd As Boolean)
        'When looping through the phrase one letter at a time, I need a single character to check for
        Dim displayedPhrase As String = splitPhrase(Session("CurrentWordState")).Replace("<br/>", "#")
        'So that the indices of both strings line up when looping
        Dim correctPhraseToCompare As String = splitPhrase(Session("HangmanWord")).Replace("<br/>", "#")

        currentWord_lit.Text = ""

        'If ending the game, show all of the missed letters
        For i As Integer = 0 To displayedPhrase.Length - 1

            If displayedPhrase.Substring(i, 1) = "*" Then
                currentWord_lit.Text &= IIf(forEnd, "<span class='WrongLetter'>" & correctPhraseToCompare.Substring(i, 1).ToUpper() & "</span>", "<span class='BlankSpace'>_</span>") & "&nbsp;&nbsp;&nbsp;"
            ElseIf displayedPhrase.Substring(i, 1) = " " Then
                currentWord_lit.Text &= "<span class='BlankSpace'>&nbsp;</span>&nbsp;&nbsp;&nbsp;"
            ElseIf displayedPhrase.Substring(i, 1) = "#" Then
                currentWord_lit.Text &= "<br />"
            Else
                currentWord_lit.Text &= "<span class='CorrectLetter'>" & displayedPhrase.Substring(i, 1).ToUpper() & "</span>&nbsp;&nbsp;&nbsp;"
            End If

        Next
    End Sub

    Private Function splitPhrase(ByVal str As String) As String

        Dim startPos As Integer = 0
        Dim totalLength As Integer = str.Length
        Dim subStr As String = ""
        Dim lastSpace As Integer = 0
        Dim currSpace As Integer = 0
        Dim newStr As String = ""

        While startPos < totalLength
            If totalLength - startPos < 13 Then
                newStr &= str.Substring(startPos, totalLength - startPos)
                startPos = totalLength
            Else
                subStr = str.Substring(startPos, 13)

                lastSpace = 0
                currSpace = InStr(subStr, " ")

                While currSpace > 0
                    lastSpace = currSpace
                    currSpace = InStr(lastSpace + 1, subStr, " ")
                End While

                If lastSpace = 0 Then
                    newStr = "Error: Too long a word."
                    Exit While
                Else
                    'For the purposes of this application, I could save myself a step by appending "#" here instead of
                    ' "<br/> (see configWordState), but I am leaving it this way for clarity
                    newStr &= subStr.Substring(0, lastSpace - 1) & "<br/>"
                    startPos += lastSpace

                End If
            End If
        End While

        Return newStr

    End Function

    Private Sub endGame(ByVal won As Boolean)
        'Disable all buttons
        For i As Int16 = Convert.ToInt16("A"c) To Convert.ToInt16("Z"c)
            Dim letter As Char = Convert.ToChar(i)
            Dim btn As Button = CType(board_pnl.FindControl(letter & "_btn"), Button)
            btn.Enabled = False
            btn.CssClass = "DisabledLetterButtonStyle"
        Next

        solve_txt.Enabled = False
        solve_btn.Enabled = False
        solve_btn.CssClass = "DisabledBigButtonStyle"

        If won Then
            hangman_img.ImageUrl = "images/hangmanWon.png"
            result_lit.Text = "<span class='CongratStyle'>You won!</span><br /><br />Good news! You're not going to die! You correctly guessed the phrase <span class='SuccessStyle'>" & Session("HangmanWord").toUpper() & "</span>."
        Else
            hangman_img.ImageUrl = "images/hangman6.png"
            result_lit.Text = "<span class='GameOverFailStyle'>You lose!</span><br /><br />You failed to guess the phrase <span class='FailStyle'>" & Session("HangmanWord").toUpper() & "</span>.<br /><br />You are now dead."
            configWordState(True)
        End If

        result_updatePnl.Update()
        result_mpExt.Show()
    End Sub

    Protected Sub resetBoard()
        board_pnl.Visible = False
        status_pnl.Visible = False
        options_pnl.Visible = True

        quit_btn.Text = "Quit Game"
        topic_ddl.SelectedValue = -1

        Session.Clear()

    End Sub

    Protected Sub instructionsClick(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim instructionsStr As String = "<h4>Welcome to Zogglet's Hangman!</h4>" & _
                                        "<p>In this game, you can select a Halo-related topic from which a random phrase will be chosen for you to guess.</p>" & _
                                        "<p>Complete the phrase by selecting letters one at a time. If a selected letter exists at least once in the " & _
                                        "hidden phrase, it will be shown in its proper place. Every time an incorrect letter is chosen, a body part of " & _
                                        "the man being hanged will be added to the gallows. If the hangman is completed, you lose. If you complete the " & _
                                        "phrase before the hangman is completed, you win.</p>" & _
                                        "<p>You can also try your luck by guessing the full phrase. If your guess is correct, you win the game. If your " & _
                                        "guess is incorrect, you instantly lose!</p>"

        instructions_lit.Text = instructionsStr

        instructions_mpExt.Show()
    End Sub

    Protected Sub closeClick(ByVal sender As Object, ByVal e As System.EventArgs)
        result_mpExt.Hide()
        quit_btn.Text = "« Start another game"
    End Sub

    Protected Sub close2Click(ByVal sender As Object, ByVal e As System.EventArgs)
        instructions_mpExt.Hide()
    End Sub


End Class
