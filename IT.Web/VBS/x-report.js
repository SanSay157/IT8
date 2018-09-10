
//===============================================================================
//:Назначение:	
//	Функция получения документа для указанного фрейма
//:Примечание:
//	Кроссбраузерный код
//:Параметры: 
//	oFrame	- [in] объект элемента iframe
//:Результат:
// 	Документ указанного фрейма. 
//	Если в силу каких-либо причин не удалось получить документ, возвращает null
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
        return null;         // Не смогли найти документ. Выходим
    }                   
}

//===============================================================================
//:Назначение:
//	Класс - контейнер параметров URL-запросов;
//	реализует логику разбора адресной строки.
//:Параметры: 
//	sURL	- [in] адресная строка
function URLParams(sURL)
{
    // адресная строка до знака ?
    this.Path = "";
    
    // Собственно, хэш-массив параметров
    this.Params = null;
    
    // адресная строка после знака #
    this.Hash = "";
    
    //---------------------------------------------------------------------------
    //:Назначение:
    //	Инициализация
    //:Параметры: 
    //	sURL	- [in] адресная строка
    this.Init = function(sURL)
    {      
        // выделяем строку после знака #
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
    //:Назначение:
    //	Функция возвращает строковое представление адресной строки с параметрами
    this.toString = function()
    {
        var sResult = "";

        for (var sKey in this.Params)
        {
            var aValues = this.Params[sKey];
            if (aValues)
            {
		// приходится вручную докодировать знак + после escape
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
    //:Назначение:
    //	Получение массива всех значений указанного параметра.
    //:Параметры: 
    //	sParamName	- [in] наименование параметра.
    //:Результат:
    //	Массив значений указанного параметра.
    //	Если параметр не найден, то метод возвращает null
    this.GetValues = function(sParamName)
    {
        var sKey = sParamName.toLowerCase();
        var aValues = this.Params[sKey];

        if (!aValues || aValues.length <= 1)
            return null;

        return aValues.slice(1);
    }

    //---------------------------------------------------------------------------
    //:Назначение:
    //	Получение значения указанного параметра.
    //:Параметры: 
    //	sParamName	- [in] наименование параметра.
    //:Результат:
    //	Значение указанного параметра.
    //	Если у параметра несколько значений, то возвращает их через запятую
    //	Если параметр не найден, то метод возвращает null
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
    //:Назначение:
    //	Добавление значения параметра. Можно передать массив значений
    //:Параметры: 
    //	sParamName	- [in] наименование параметра.
    //	vParamValue	- [in] значение параметра.
    this.AddValue = function(sParamName, vParamValue)
    {
        if (vParamValue == null)
            return;
        var sKey = sParamName.toLowerCase();
        var aValues = this.Params[sKey];

        // 1й элемент массива - наименование параметра в правильном регистре
        if (!aValues)
            aValues = [sParamName];
        else
            aValues[0] = sParamName;

        if (typeof(vParamValue) == "object" && vParamValue["length"] != null)
            aValues = aValues.concat(vParamValue);		// массив
        else
            aValues[aValues.length] = vParamValue;		// простое значение

        this.Params[sKey] = aValues;
    }


    //---------------------------------------------------------------------------
    //:Назначение:
    //	Установка значения параметра. Можно передать массив значений
    //	Старое значение параметра (если было) замещается новым.
    //:Примечание:
    //	Чтобы удалить параметр, надо передать в качестве значения null
    //:Параметры: 
    //	sParamName	- [in] наименование параметра.
    //	vParamValue	- [in] значение параметра.    
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

        // 1й элемент массива - наименование параметра в правильном регистре
        if (typeof(vParamValue) == "object" && vParamValue["length"] != null)
            aValues = [sParamName].concat(vParamValue);		// массив
        else
            aValues = [sParamName, vParamValue];		// простое значение

        this.Params[sKey] = aValues;
    }
    
    this.Init(sURL);
}

//===============================================================================
//:Назначение:
//	Класс для работы с параметрами, переданными через POST, 
//	и возвращенными в виде JSON объекта aFormPostData 
function FormPostData()
{
    //---------------------------------------------------------------------------
    //:Назначение:
    //	Инициализация (приватный метод)
    //:Параметры: 
    //	oSelf		- [in] ссылка на свой объект, ибо IE теряет ссылку на this из-за того, что метод приватный
    Init = function(oSelf)
    {
        // Пытаемся найти POST данные в предопределенном объекте aFormPostData (формат объекта фиксирован!)
        // либо в своем окне, либо в окне верхнего уровня.
        if (typeof(window["aFormPostData"]) == "object")
            oSelf.Params = window["aFormPostData"];
        else
        if (typeof(window.top["aFormPostData"]) == "object")
            oSelf.Params = window.top["aFormPostData"];
    }

    //---------------------------------------------------------------------------
    //:Назначение:
    //	Метод отправки значений по указанной адресной строке через POST
    //:Параметры: 
    //	oWindow		- [in] Окно, в котором будет создана форма для отправки значений
    //	sURL		- [in] URL, по которому отправляются данные
    //	sTarget		- [in] Указание окна, в которое будет загружен ответ сервера
    //				См. одноименный параметр у window.open
    this.Submit = function(oWindow, sURL, sTarget)
    {
        // создаем в документе скрытую форму, в которую сложим POST параметры,
        // и переходим по указанному УРЛ с передачей параметров на сервер
        var oDoc = oWindow.document;
        var oForm = oDoc.getElementById("PostDataForm");
        if (oForm)
            // Если форма уже существует, сперва удалим старую
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
            // нет данных для POST. Обойдемся GET
            if (!sTarget)
                sTarget = "_self";
            oWindow.setTimeout('open("' + sURL + '", "' + sTarget + '")', 50);
        }
        else
        {
            // шлем через POST
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

// "наследуемся" от класса работы с параметрами адресной строки,
// чтобы использовать методы, реализованные в URLParams
FormPostData.prototype = new URLParams("");
