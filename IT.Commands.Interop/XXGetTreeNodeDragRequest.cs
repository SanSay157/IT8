using System;
using Croc.XmlFramework.Public;
using Croc.XmlFramework.Commands;

namespace Croc.XmlFramework.Extension.Commands 
{
	/// <summary>
	/// ������, �������������� ������ ������� �� ���������� �������� ���������
	/// XML-�������� �������� �������� ��� ���� �������� <b>GetTreeNodeDrag</b> (��. ����������
	/// �������� XGetTreeNodeDragCommand).
	/// </summary>                                            
	[Serializable]
	public class XXGetTreeNodeDragRequest : XTreeBaseRequest 
	{
		/// <summary>
		/// ������������ �������� � ������� �������� �� ���������.
		/// </summary>
		private const string DEF_COMMAND_NAME = "GetTreeNodeDrag";
		
		#region ������������ ������� ������� 
		
		/// <summary>
		/// ����������� �� ���������, �������������� �������� MetaName />
		/// ��������� null, �������� Path />
		/// \- ����������� ������� XTreePath />,
		/// �������������� ������ &quot;����&quot;. 
		/// </summary>                                                                                                                           
		public XXGetTreeNodeDragRequest()
			: base(DEF_COMMAND_NAME) 
		{}

		
		/// <summary>
		/// ������������������� �����������.
		/// </summary>
		/// <param name="metaName">������ (System.String) � �������������
		///                        ����������� ��������� �������� � ����������;
		///                        �������������� �������� �������� MetaName.
		///                        ������� �������� ��������� �����������; �������
		///                        null ��� ������ ������ ����������� \- � ����
		///                        ������ ����� ������������� ���������� ArgumentNullException
		///                        ��� ArgumentException
		///                        ��������������. </param>
		/// <exception cref="ArgumentException">���� � �������� ��������
		///                                     ��������� <b><i>metaName</i></b>
		///                                     ������ ������ ������. </exception>
		/// <exception cref="ArgumentNullException">���� �������� <b><i>metaName</i></b>
		///                                         ����� � null. </exception>                                                                          
		public XXGetTreeNodeDragRequest(string metaName) 
			: base(DEF_COMMAND_NAME) 
		{
			this.MetaName = metaName;
		}

		
		/// <summary>
		/// ������������������� �����������.
		/// </summary>
		/// <param name="metaName">������ (System.String) � �������������
		///                        ����������� ��������� �������� � ����������;
		///                        �������������� �������� �������� MetaName.
		///                        ������� �������� ��������� �����������; �������
		///                        null ��� ������ ������ ����������� \- � ����
		///                        ������ ����� ������������� ���������� ArgumentNullException
		///                        ��� ArgumentException
		///                        ��������������. </param>
		/// <param name="treePath">��������� ������� XTreePath,
		///                        �������� &quot;����&quot; ��� ���� � ��������,
		///                        ��� �������� ��������� �������� �������� ����;
		///                        �������������� �������� �������� Path.<para></para>����
		///                        �������� ������ XTreePath
		///                        ��������� ������ ���� (�.�. &quot;�����&quot;
		///                        ���� Length
		///                        �������) \- �� �������� ��������� ���������
		///                        ������ ��� ������ �������� (������������
		///                        ��������� <b>i\:empty\-tree\-menu</b>). </param>
		/// <exception cref="ArgumentException">���� � �������� ��������
		///                                     ��������� <b><i>metaName</i></b>
		///                                     ������ ������ ������. </exception>
		/// <exception cref="ArgumentNullException">���� �������� <b><i>metaName</i></b>
		///                                         ����� � null. </exception>                                                                                   
		public XXGetTreeNodeDragRequest(string metaName, XTreePath treePath)
			: base(DEF_COMMAND_NAME) 
		{
			MetaName = metaName;
			Path = treePath;
		}


		#endregion


		/// <summary>
		/// ����� �������� ������ �������. 
		/// ���������� ����� ����� ��������� ������� � ���������� ���.
		/// </summary>
		/// <remarks>
		/// ����� ���������, ����� ������������ �������� ��������� �������� � 
		/// ���������� ���� ������ (���� ��� � ���������� ������� XML-�������).
		/// </remarks>
		public override void Validate() 
		{
			// �������� ������� ���������� - �������� ������� �������� ������
			base.Validate();

			// ������������ �������� ��������� �������� � ���������� ������ 
			// ���� ������ (���� ��� � ���������� ������� XML-�������):
			XRequest.ValidateRequiredArgument( MetaName, "MetaName" );
		}
	}
}