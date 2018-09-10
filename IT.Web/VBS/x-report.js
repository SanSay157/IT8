
//===============================================================================
//:����������:	
//	������� ��������� ��������� ��� ���������� ������
//:����������:
//	��������������� ���
//:���������: 
//	oFrame	- [in] ������ �������� iframe
//:���������:
// 	�������� ���������� ������. 
//	���� � ���� �����-���� ������ �� ������� �������� ��������, ���������� null
function GetFrameDocument(oFrame)
{
    if (!oFrame)
        return null;
    try
    {
        var oDoc = oFrame.contentDocument;
        if (!oDoc && oFrame.contentWindow)
            oDoc = oFrame.contentWindow.document;
        if (!oDoc)
            oDoc = window.frames[oFrame.id].document;
            
        return oDoc;
    }
    catch(oE)
    {
        return null;         // �� ������ ����� ��������. �������
    }                   
}

//===============================================================================
//:����������:
//	����� - ��������� ���������� URL-��������;
//	��������� ������ ������� �������� ������.
//:���������: 
//	sURL	- [in] �������� ������
function URLParams(sURL)
{
    // �������� ������ �� ����� ?
    this.Path = "";
    
    // ����������, ���-������ ����������
    this.Params = null;
    
    // �������� ������ ����� ����� #
    this.Hash = "";
    
    //---------------------------------------------------------------------------
    //:����������:
    //	�������������
    //:���������: 
    //	sURL	- [in] �������� ������
    this.Init = function(sURL)
    {      
        // �������� ������ ����� ����� #
        var iPos = sURL.indexOf("#");
        if (iPos >= 0)
        {
            this.Hash = sURL.substr(iPos + 1);
            sURL = sURL.substring(0, iPos);
        }
        
        this.Params = {};   
        iPos = sURL.indexOf("?");
        if (iPos < 0)
        {
            this.Path = sURL;
            return;
        }
        
        this.Path = sURL.substring(0, iPos);
        var aPar = sURL.substr(iPos + 1).split("&");
        for (var i = 0; i < aPar.length; i++)
        {
            iPos = aPar[i].indexOf("=");
            if (iPos < 0)
                this.AddValue(unescape(aPar[i]), "");
            else
                this.AddValue(unescape(aPar[i].substring(0, iPos)), unescape(aPar[i].substr(iPos + 1)));
        }
    }

    //---------------------------------------------------------------------------
    //:����������:
    //	������� ���������� ��������� ������������� �������� ������ � �����������
    this.toString = function()
    {
        var sResult = "";

        for (var sKey in this.Params)
        {
            var aValues = this.Params[sKey];
            if (aValues)
            {
		// ���������� ������� ������������ ���� + ����� escape
                var sParamName = escape(aValues[0]).replace("+", "%2B");
                for (var i = 1; i < aValues.length; i++)
                    sResult += sParamName + "=" + escape(aValues[i]).replace("+", "%2B") + "&";
            }
        }

        if (sResult.length)
            sResult = "?" + sResult.substring(0, sResult.length - 1);

        return this.Path + sResult + 
               ((this.Hash.length) ? "#" + this.Hash : "");
    }

    //---------------------------------------------------------------------------
    //:����������:
    //	��������� ������� ���� �������� ���������� ���������.
    //:���������: 
    //	sParamName	- [in] ������������ ���������.
    //:���������:
    //	������ �������� ���������� ���������.
    //	���� �������� �� ������, �� ����� ���������� null
    this.GetValues = function(sParamName)
    {
        var sKey = sParamName.toLowerCase();
        var aValues = this.Params[sKey];

        if (!aValues || aValues.length <= 1)
            return null;

        return aValues.slice(1);
    }

    //---------------------------------------------------------------------------
    //:����������:
    //	��������� �������� ���������� ���������.
    //:���������: 
    //	sParamName	- [in] ������������ ���������.
    //:���������:
    //	�������� ���������� ���������.
    //	���� � ��������� ��������� ��������, �� ���������� �� ����� �������
    //	���� �������� �� ������, �� ����� ���������� null
    this.GetValue = function(sParamName)
    {
        var aValues = this.GetValues(sParamName);

        if (!(aValues && aValues.length))
            return null;

        if (aValues.length == 1)
            return aValues[0];
        else
            return aValues.join(",");
    }

    //---------------------------------------------------------------------------
    //:����������:
    //	���������� �������� ���������. ����� �������� ������ ��������
    //:���������: 
    //	sParamName	- [in] ������������ ���������.
    //	vParamValue	- [in] �������� ���������.
    this.AddValue = function(sParamName, vParamValue)
    {
        if (vParamValue == null)
            return;
        var sKey = sParamName.toLowerCase();
        var aValues = this.Params[sKey];

        // 1� ������� ������� - ������������ ��������� � ���������� ��������
        if (!aValues)
            aValues = [sParamName];
        else
            aValues[0] = sParamName;

        if (typeof(vParamValue) == "object" && vParamValue["length"] != null)
            aValues = aValues.concat(vParamValue);		// ������
        else
            aValues[aValues.length] = vParamValue;		// ������� ��������

        this.Params[sKey] = aValues;
    }


    //---------------------------------------------------------------------------
    //:����������:
    //	��������� �������� ���������. ����� �������� ������ ��������
    //	������ �������� ��������� (���� ����) ���������� �����.
    //:����������:
    //	����� ������� ��������, ���� �������� � �������� �������� null
    //:���������: 
    //	sParamName	- [in] ������������ ���������.
    //	vParamValue	- [in] �������� ���������.    
    this.SetValue = function(sParamName, vParamValue)
    {
        var sKey = sParamName.toLowerCase();
        var aValues = this.Params[sKey];

        if (vParamValue == null)
        {
            if (aValues)
                this.Params[sKey] = null;
            return;
        }

        // 1� ������� ������� - ������������ ��������� � ���������� ��������
        if (typeof(vParamValue) == "object" && vParamValue["length"] != null)
            aValues = [sParamName].concat(vParamValue);		// ������
        else
            aValues = [sParamName, vParamValue];		// ������� ��������

        this.Params[sKey] = aValues;
    }
    
    this.Init(sURL);
}

//===============================================================================
//:����������:
//	����� ��� ������ � �����������, ����������� ����� POST, 
//	� ������������� � ���� JSON ������� aFormPostData 
function FormPostData()
{
    //---------------------------------------------------------------------------
    //:����������:
    //	������������� (��������� �����)
    //:���������: 
    //	oSelf		- [in] ������ �� ���� ������, ��� IE ������ ������ �� this ��-�� ����, ��� ����� ���������
    Init = function(oSelf)
    {
        // �������� ����� POST ������ � ���������������� ������� aFormPostData (������ ������� ����������!)
        // ���� � ����� ����, ���� � ���� �������� ������.
        if (typeof(window["aFormPostData"]) == "object")
            oSelf.Params = window["aFormPostData"];
        else
        if (typeof(window.top["aFormPostData"]) == "object")
            oSelf.Params = window.top["aFormPostData"];
    }

    //---------------------------------------------------------------------------
    //:����������:
    //	����� �������� �������� �� ��������� �������� ������ ����� POST
    //:���������: 
    //	oWindow		- [in] ����, � ������� ����� ������� ����� ��� �������� ��������
    //	sURL		- [in] URL, �� �������� ������������ ������
    //	sTarget		- [in] �������� ����, � ������� ����� �������� ����� �������
    //				��. ����������� �������� � window.open
    this.Submit = function(oWindow, sURL, sTarget)
    {
        // ������� � ��������� ������� �����, � ������� ������ POST ���������,
        // � ��������� �� ���������� ��� � ��������� ���������� �� ������
        var oDoc = oWindow.document;
        var oForm = oDoc.getElementById("PostDataForm");
        if (oForm)
            // ���� ����� ��� ����������, ������ ������ ������
            oForm.parentNode.removeChild(oForm);

        oForm = oDoc.createElement("FORM");
        for (var sKey in this.Params)
        {
            var aValues = this.Params[sKey];
            if (aValues)
            {
                var sParamName = aValues[0];
                for (var i = 1; i < aValues.length; i++)
                {
                    var oInput = oDoc.createElement("INPUT");
                    oInput.setAttribute("type", "hidden");
                    oInput.setAttribute("name", sParamName);
                    oInput.setAttribute("value", aValues[i]);
                    oForm.appendChild(oInput);
                }
            }
        }

        if (!oForm.childNodes.length)
        {
            // ��� ������ ��� POST. ��������� GET
            if (!sTarget)
                sTarget = "_self";
            oWindow.setTimeout('open("' + sURL + '", "' + sTarget + '")', 50);
        }
        else
        {
            // ���� ����� POST
            oForm.setAttribute("id", "PostDataForm");
            oForm.setAttribute("method", "POST");
            oForm.setAttribute("action", sURL);
            if (sTarget)
                oForm.setAttribute("target", sTarget);

            oDoc.body.appendChild(oForm);
            oWindow.setTimeout('document.getElementById("PostDataForm").submit()', 50);
        }
    }

    Init(this);
}

// "�����������" �� ������ ������ � ����������� �������� ������,
// ����� ������������ ������, ������������� � URLParams
FormPostData.prototype = new URLParams("");
