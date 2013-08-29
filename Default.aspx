<%@ Page Language="VB" AutoEventWireup="false" CodeFile="Default.aspx.vb" Inherits="_Default" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Zogglet's Hangman: A Game by Maggy Maffia</title>
    <link href="style.css" rel="stylesheet" type="text/css" />
    <link href="favicon.ico" rel="icon" type="image/x-icon" />
    
</head>
<body>
    <form id="form1" runat="server">
    
        <%--Required for use of AJAX Control Toolkit --%>
        <asp:ToolkitScriptManager ID="ToolkitScriptManager1" runat="server" />
    
        <h1>Zogglet's Hangman</h1>
        <h2>A Game by Maggy Maffia</h2>
        
        <div id="outer_div">
        
            <table id="outer_table">
                <tr>
                    <td class="options_area">
                        Welcome to <b>Zogglet's Hangman</b>, a Halo-themed Hangman game!
                        <br /><br />
                        <asp:UpdatePanel ID="optionsStatus_updatePnl" runat="server" UpdateMode="Conditional">
                            <ContentTemplate>
                            
                                <asp:Panel ID="options_pnl" runat="server">
                                    <table width="100%">
                                        <tr>
                                            <td>
                                                <asp:DropDownList ID="topic_ddl" runat="server" CssClass="InputStyle" DataSourceID="topic_sds" DataTextField="Topic" DataValueField="ID" />
                                                
                                                <asp:SqlDataSource ID="topic_sds" runat="server" ConnectionString="<%$ ConnectionStrings:HangmanConnectionString %>" 
                                                        SelectCommand="SELECT ID, Topic FROM Topics UNION SELECT '-1' AS ID, '&laquo; Select Topic &raquo;' AS Topic ORDER BY ID" />
                                                        
                                                <asp:CompareValidator ID="topic_cVal" runat="server" ControlToValidate="topic_ddl" Operator="NotEqual" 
                                                    ValueToCompare="-1" ErrorMessage="Please select a topic first." Display="None" />
                                                <asp:ValidatorCalloutExtender ID="topic_vcExt" runat="server" TargetControlID="topic_cVal" WarningIconImageUrl="warningIcon.png" 
                                                    CloseImageUrl="closeIcon.png" CssClass="ValidatorCalloutStyle" />
                                            </td>
                                            <td align="right">
                                                <asp:Button ID="instructions_btn" runat="server" Text="Instructions" CssClass="ButtonStyle" CausesValidation="false" OnClick="instructionsClick" />
                                                &nbsp;<asp:Button ID="startNew_btn" runat="server" Text="Start New Game &raquo;" CssClass="ButtonStyle" OnClick="prepareBoard" />
                                            </td>
                                        </tr>
                                    </table>
                                </asp:Panel>
                                
                                <asp:Panel ID="status_pnl" runat="server" Visible="false">
                                    <table width="100%">
                                        <tr>
                                            <td>
                                                <asp:Literal ID="topic_lit" runat="server" />
                                            </td>
                                            <td>
                                                <asp:Literal ID="status_lit" runat="server" />
                                            </td>
                                            <td align="right">
                                                <asp:Button ID="quit_btn" runat="server" Text="Quit Game" CssClass="ButtonStyle" CausesValidation="false" OnClick="resetBoard" />
                                            </td>
                                        </tr>
                                    </table>
                                </asp:Panel>
                                
                            </ContentTemplate>
                            <Triggers>
                                <asp:AsyncPostBackTrigger ControlID="startNew_btn" EventName="Click" />
                                <asp:AsyncPostBackTrigger ControlID="quit_btn" EventName="Click" />
                                <asp:AsyncPostBackTrigger ControlID="close_lBtn" EventName="Click" />
                            </Triggers>
                        </asp:UpdatePanel>
                    </td>
                </tr>
                
                
                <tr>
                    <td>
                        <asp:UpdatePanel ID="board_updatePnl" runat="server" UpdateMode="Conditional" ChildrenAsTriggers="true">
                            <ContentTemplate>
                                <asp:Panel ID="board_pnl" runat="server" Visible="false">
                                
                                    <span class="Divider">&nbsp;</span>
                                    <br />
                                    
                                    <table class="BoardTable">
                                        <tr>
                                            <td>
                                                <asp:Image ID="hangman_img" runat="server" />
                                            </td>
                                            <td>
                                                <asp:Literal ID="currentWord_lit" runat="server" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan="2">
                                                <span class="Divider">&nbsp;</span>
                                                <br />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="options_area" colspan="2">
                                                <table width="100%">
                                                    <tr>
                                                        <td><asp:Button ID="a_btn" runat="server" Text="A" CommandArgument="A" OnCommand="letterCommand" CssClass="LetterButtonStyle" /></td>
                                                        <td><asp:Button ID="b_btn" runat="server" Text="B" CommandArgument="B" OnCommand="letterCommand" CssClass="LetterButtonStyle" /></td>
                                                        <td><asp:Button ID="c_btn" runat="server" Text="C" CommandArgument="C" OnCommand="letterCommand" CssClass="LetterButtonStyle" /></td>
                                                        <td><asp:Button ID="d_btn" runat="server" Text="D" CommandArgument="D" OnCommand="letterCommand" CssClass="LetterButtonStyle" /></td>
                                                        <td><asp:Button ID="e_btn" runat="server" Text="E" CommandArgument="E" OnCommand="letterCommand" CssClass="LetterButtonStyle" /></td>
                                                        <td><asp:Button ID="f_btn" runat="server" Text="F" CommandArgument="F" OnCommand="letterCommand" CssClass="LetterButtonStyle" /></td>
                                                        <td><asp:Button ID="g_btn" runat="server" Text="G" CommandArgument="G" OnCommand="letterCommand" CssClass="LetterButtonStyle" /></td>
                                                        <td><asp:Button ID="h_btn" runat="server" Text="H" CommandArgument="H" OnCommand="letterCommand" CssClass="LetterButtonStyle" /></td>
                                                        <td><asp:Button ID="i_btn" runat="server" Text="I" CommandArgument="I" OnCommand="letterCommand" CssClass="LetterButtonStyle" /></td>
                                                        <td><asp:Button ID="j_btn" runat="server" Text="J" CommandArgument="J" OnCommand="letterCommand" CssClass="LetterButtonStyle" /></td>
                                                        <td><asp:Button ID="k_btn" runat="server" Text="K" CommandArgument="K" OnCommand="letterCommand" CssClass="LetterButtonStyle" /></td>
                                                        <td><asp:Button ID="l_btn" runat="server" Text="L" CommandArgument="L" OnCommand="letterCommand" CssClass="LetterButtonStyle" /></td>
                                                        <td><asp:Button ID="m_btn" runat="server" Text="M" CommandArgument="M" OnCommand="letterCommand" CssClass="LetterButtonStyle" /></td>
                                                    </tr>
                                                    <tr>
                                                        <td><asp:Button ID="n_btn" runat="server" Text="N" CommandArgument="N" OnCommand="letterCommand" CssClass="LetterButtonStyle" /></td>
                                                        <td><asp:Button ID="o_btn" runat="server" Text="O" CommandArgument="O" OnCommand="letterCommand" CssClass="LetterButtonStyle" /></td>
                                                        <td><asp:Button ID="p_btn" runat="server" Text="P" CommandArgument="P" OnCommand="letterCommand" CssClass="LetterButtonStyle" /></td>
                                                        <td><asp:Button ID="q_btn" runat="server" Text="Q" CommandArgument="Q" OnCommand="letterCommand" CssClass="LetterButtonStyle" /></td>
                                                        <td><asp:Button ID="r_btn" runat="server" Text="R" CommandArgument="R" OnCommand="letterCommand" CssClass="LetterButtonStyle" /></td>
                                                        <td><asp:Button ID="s_btn" runat="server" Text="S" CommandArgument="S" OnCommand="letterCommand" CssClass="LetterButtonStyle" /></td>
                                                        <td><asp:Button ID="t_btn" runat="server" Text="T" CommandArgument="T" OnCommand="letterCommand" CssClass="LetterButtonStyle" /></td>
                                                        <td><asp:Button ID="u_btn" runat="server" Text="U" CommandArgument="U" OnCommand="letterCommand" CssClass="LetterButtonStyle" /></td>
                                                        <td><asp:Button ID="v_btn" runat="server" Text="V" CommandArgument="V" OnCommand="letterCommand" CssClass="LetterButtonStyle" /></td>
                                                        <td><asp:Button ID="w_btn" runat="server" Text="W" CommandArgument="W" OnCommand="letterCommand" CssClass="LetterButtonStyle" /></td>
                                                        <td><asp:Button ID="x_btn" runat="server" Text="X" CommandArgument="X" OnCommand="letterCommand" CssClass="LetterButtonStyle" /></td>
                                                        <td><asp:Button ID="y_btn" runat="server" Text="Y" CommandArgument="Y" OnCommand="letterCommand" CssClass="LetterButtonStyle" /></td>
                                                        <td><asp:Button ID="z_btn" runat="server" Text="Z" CommandArgument="Z" OnCommand="letterCommand" CssClass="LetterButtonStyle" /></td>
                                                    </tr>
                                                    <tr>
                                                        <td colspan="13">
                                                            <span class="InnerBigStyle">or</span>
                                                            <br /><asp:TextBox ID="solve_txt" runat="server" CssClass="SolveInputStyle" Width="310px" />
                                                            &nbsp;<asp:Button ID="solve_btn" runat="server" Text="Solve" ValidationGroup="solve_vGroup" CssClass="BigButtonStyle" OnClick="solveClick" />
                                                            
                                                            <asp:RequiredFieldValidator ID="solve_rVal" runat="server" ValidationGroup="solve_vGroup" ControlToValidate="solve_txt" ErrorMessage="Please enter a solution first." Display="None" />
                                                            <asp:ValidatorCalloutExtender ID="solve_vcExt" runat="server" TargetControlID="solve_rVal" WarningIconImageUrl="warningIcon.png" 
                                                                CloseImageUrl="closeIcon.png" CssClass="ValidatorCalloutStyle" />
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                    </table>
                                    
                                    
                                </asp:Panel>
                            </ContentTemplate>
                            <Triggers>
                                <asp:AsyncPostBackTrigger ControlID="startNew_btn" EventName="Click" />
                                <asp:AsyncPostBackTrigger ControlID="quit_btn" EventName="Click" />
                                <asp:AsyncPostBackTrigger ControlID="close_lBtn" EventName="Click" />
                            </Triggers>
                        </asp:UpdatePanel>
                    </td>
                </tr>
            </table>
            
            <%--Instructions Modal Popup--%>
            <asp:DropShadowExtender ID="instructions_dsExt" runat="server" TargetControlID="instructions_pnl" Opacity=".15" Width="4" TrackPosition="true" />
            
            <asp:ModalPopupExtender ID="instructions_mpExt" runat="server" TargetControlID="dummy" PopupControlID="instructions_pnl" />
            <input type="button" id="dummy" runat="server" style="display: none;" />
            
            <asp:Panel ID="instructions_pnl" runat="server" CssClass="ModalStyle" Width="350px">
                
                <asp:UpdatePanel ID="instructions_updatePnl" runat="server" UpdateMode="Conditional">
                    <ContentTemplate>
                        <asp:Literal ID="instructions_lit" runat="server" />
                    </ContentTemplate>
                    <Triggers>
                        <asp:AsyncPostBackTrigger ControlID="instructions_btn" EventName="Click" />
                        <asp:AsyncPostBackTrigger ControlID="close_lBtn2" EventName="Click" />
                    </Triggers>
                </asp:UpdatePanel>
                
                <span style="text-align: center; width:100%; display: block;"><asp:LinkButton ID="close_lBtn2" runat="server" Text="[Close]" OnClick="close2Click" CausesValidation="false" /></span>
            </asp:Panel>
            
            <%--Result Modal Popup--%>
            <asp:ModalPopupExtender ID="result_mpExt" runat="server" TargetControlID="dummy2" PopupControlID="result_pnl" />
            <input type="button" id="dummy2" runat="server" style="display: none;" />
            
            <asp:Panel ID="result_pnl" runat="server" CssClass="ResultStyle">
            
                <asp:UpdatePanel ID="result_updatePnl" runat="server" UpdateMode="Conditional">
                    <ContentTemplate>
                        <asp:Literal ID="result_lit" runat="server" />
                    </ContentTemplate>
                    <Triggers>
                        <asp:AsyncPostBackTrigger ControlID="quit_btn" EventName="Click" />
                    </Triggers>
                </asp:UpdatePanel>
                
                <br />
                <span class="inner"><asp:LinkButton ID="close_lBtn" runat="server" Text="[Close]" OnClick="closeClick" CausesValidation="false" /></span>
                            
            </asp:Panel>
            
            
        </div>
        
        <div class="Footer">
            Copyright &copy; 2012, <a href="mailto:maggy@zogglet.com?subject=About your awesome Hangman game">Maggy Maffia</a>
        </div>
        
    </form>
</body>
</html>
