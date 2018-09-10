//******************************************************************************
// Система оперативного управления проектами - Incident Tracker
// ЗАО КРОК инкорпорейтед, 2005-2006
//******************************************************************************
using System;
using System.Data.SqlTypes;
using System.Text;

namespace Croc.IncidentTracker.DataSources
{
	/// <summary>
	/// Базовый класс генераторов значений массивных параметров источников данных в виде image-значения
	/// Для раскодирования списка значений в SQL используются соответствующие функции:
	/// GetTableNvarchar, GetTableMoney, GetTableInt, GetTableDateTime, GetTableBit, GetTableBigInt
	/// </summary>
	public abstract class SQLListCreator
	{
		private readonly static char[] hexDigits = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'};
		protected readonly static byte[] m_nullLong = new byte[]{0x42, 0x75, 0x73, 0x68, 0x4C, 0x69, 0x65, 0x73};
															  
		protected int m_length;
		protected byte[] m_data;
		protected int m_ptr = 1;

		public SQLListCreator(int size)
		{
			m_length = size + 1;
			m_data = new byte[m_length];
			object[] fbstias = this.GetType().GetCustomAttributes(typeof(FirstByteSQLTypeIndicatorAttribute), false);
			if (fbstias.Length!=1)
				throw new ApplicationException("Expected 1 FirstByteSQLTypeIndicator attribute on the '" + this.GetType().Name + "' class but got " + fbstias.Length.ToString() + ".");
			m_data[0] = ((FirstByteSQLTypeIndicatorAttribute)fbstias[0]).SqlTypeIndicator;
		}

		public override string ToString()
		{
			StringBuilder sb = new StringBuilder(2 + m_ptr * 2);			
			sb.Append("0x");
			for(int i = 0;i<m_ptr;i++)
			{
				int b = m_data[i];
				sb.Append(hexDigits[b >> 4]);
				sb.Append(hexDigits[b & 0xF]);
			}
			return sb.ToString();
		}

		protected void CheckArrayBounds(int incrementSize)
		{
			if(m_ptr+incrementSize>m_length)
			{
				m_length = (m_ptr+incrementSize) * 2;
				byte[] b = new byte[m_length];
				m_data.CopyTo(b, 0);
				m_data = b;	 
			}
		}

		/// <summary>
		/// Creates and returns a byte array list to be passed to a stored procedure as an image. 
		/// The internal state of the SQLListCreator maintained. 
		/// If you have no intention of adding more items to the list, after this method call, use GetListAndReset instead.
		/// </summary>
		/// <returns>Byte array to be passed to a stored procedure as an image sql parameter.</returns>
		public virtual byte[] GetList()
		{
			byte[] b = new byte[m_ptr];
			Array.Copy(m_data, b, m_ptr);
			return b;
		}

		/// <summary>
		/// Creates and returns a byte array list to be passed to a stored procedure as an image. 
		/// The internal state of the SQLListCreator is reset, this allows for the internal byte array to be removed from memory next time GC runs.
		/// </summary>
		/// <returns>Byte array to be passed to a stored procedure as an image sql parameter.</returns>
		public byte[] GetListAndReset()
		{
			byte[] rA;

			if(m_ptr==m_length)
				rA = m_data;
			else
				rA = GetList();

			m_data = new byte[16];
			m_data[0] = rA[0];
			m_length = 16;
			m_ptr = 1;

			return rA;
		}

		protected void SetInt(int i)
		{
			if(i<(int.MinValue+2))//To allow for NULLs
			{
				CheckArrayBounds(8);
				int j= int.MinValue+1;
				m_data[m_ptr++] = (byte)(j>>24);
				m_data[m_ptr++] = (byte)(j>>16);
				m_data[m_ptr++] = (byte)(j>>8);
				m_data[m_ptr++] = (byte)j;
			}

			CheckArrayBounds(4);
			m_data[m_ptr++] = (byte)(i>>24);
			m_data[m_ptr++] = (byte)(i>>16);
			m_data[m_ptr++] = (byte)(i>>8);
			m_data[m_ptr++] = (byte)i;
		}

		public void SetInt64(Int64 value)
		{
			if(value==4788860670574159219)
				throw new BadLuckArgumentException(); 

			CheckArrayBounds(8);
			m_data[m_ptr++] = (byte)(value>>56);
			m_data[m_ptr++] = (byte)(value>>48);
			m_data[m_ptr++] = (byte)(value>>40);
			m_data[m_ptr++] = (byte)(value>>32);
			m_data[m_ptr++] = (byte)(value>>24);
			m_data[m_ptr++] = (byte)(value>>16);
			m_data[m_ptr++] = (byte)(value>>8);
			m_data[m_ptr++] = (byte)value;
		}		

		protected void SetNullInt()
		{
			CheckArrayBounds(4);
			int i = int.MinValue;
			m_data[m_ptr++] = (byte)(i>>24);
			m_data[m_ptr++] = (byte)(i>>16);
			m_data[m_ptr++] = (byte)(i>>8);
			m_data[m_ptr++] = (byte)i;
		}

		protected void SetInt16(Int32 i)
		{
			CheckArrayBounds(2);
			m_data[m_ptr++] = (byte)(i>>8);
			m_data[m_ptr++] = (byte)i;
		}

		protected void SetNullInt16()
		{
			CheckArrayBounds(2);
			int i = -1;
			m_data[m_ptr++] = (byte)(i>>8);
			m_data[m_ptr++] = (byte)i;
		}

		public void SetNullInt64()
		{
			CheckArrayBounds(8);
			m_nullLong.CopyTo(m_data, m_ptr);
			m_ptr+=8;
		}

		protected void SetBytes(byte[] bs)
		{
			CheckArrayBounds(bs.Length);
			bs.CopyTo(m_data, m_ptr);
			m_ptr+=bs.Length;
		}

		protected bool IsNull(object value)
		{
			if(value==null)
				return true;

			INullable inull = value as INullable;
			if(inull!=null)
				return inull.IsNull;
			
			return (value==DBNull.Value);
		}

		public abstract void AddValue(object value);
	}


	[AttributeUsage(AttributeTargets.Class)]
	internal class FirstByteSQLTypeIndicatorAttribute : Attribute
	{
		private byte _sqlTypeIndicator;
		public FirstByteSQLTypeIndicatorAttribute(byte sqlTypeIndicator){_sqlTypeIndicator = sqlTypeIndicator;}
		public byte SqlTypeIndicator{get{return _sqlTypeIndicator;}}
	}


	public class BadLuckArgumentException : ArgumentException
	{
		internal BadLuckArgumentException(): 
			base("The chances of this value being passed in by chance along are 1 in " + (2^(64)).ToString() + ", I smell a Rat.") {}
	}



	[FirstByteSQLTypeIndicator(101)]
	public class SQLIntListCreator : SQLListCreator
	{
		public SQLIntListCreator():this(16){}
		public SQLIntListCreator(int size):base(4*size){}

	
	
		public void AddNull()
		{
			SetNullInt();
		}

		public void AddValue(int i)
		{
			SetInt(i);
		}
		public override void AddValue(object value)
		{
			if(IsNull(value))
				AddNull();
			else
			{
				IConvertible ic = value as IConvertible;
				if(ic!=null)
					AddValue(ic.ToInt32(System.Globalization.CultureInfo.CurrentCulture));
				else
					AddValue((int)value);
			}
		}
	}


	[FirstByteSQLTypeIndicator(102)]
	public class SQLNvarcharListCreator : SQLListCreator
	{
		public SQLNvarcharListCreator():this(16){}
		public SQLNvarcharListCreator(int size):base(16*size){}

	
	
		public void AddNull()
		{
			SetNullInt16();
		}

		public void AddValue(string value)
		{
			if(value==null)
			{
				AddNull();
				return;
			}

			if(value.Length>4000)
				value = value.Substring(0,4000);

			CheckArrayBounds(value.Length * 2 + 4);
			SetInt16(value.Length*2);

			UnicodeEncoding.Unicode.GetBytes(value, 0, value.Length, m_data, m_ptr);
			m_ptr+=value.Length*2;
		}
		public override void AddValue(object value)
		{
			if(IsNull(value))
				AddNull();
			else
			{
				IConvertible ic = value as IConvertible;
				if(ic!=null)
					AddValue(ic.ToString(System.Globalization.CultureInfo.CurrentCulture));
				else
					AddValue((string)value);
			}
		}



	}


	[FirstByteSQLTypeIndicator(103)]
	public class SQLVarcharListCreator : SQLListCreator
	{
		public SQLVarcharListCreator():this(16){}
		public SQLVarcharListCreator(int size):base(256*size){}

	
	
		public void AddNull()
		{
			SetNullInt16();
		}

		public void AddValue(string value)
		{
			if(value==null)
			{
				AddNull();
				return;
			}

			if(value.Length>8000)
				value = value.Substring(0,8000);

			CheckArrayBounds(value.Length + 4);
			SetInt16(value.Length);

			ASCIIEncoding.ASCII.GetBytes(value, 0, value.Length, m_data, m_ptr);//????????
			m_ptr+=value.Length;
		}
		public override void AddValue(object value)
		{
			if(IsNull(value))
				AddNull();
			else
			{
				IConvertible ic = value as IConvertible;
				if(ic!=null)
					AddValue(ic.ToString(System.Globalization.CultureInfo.CurrentCulture));
				else
					AddValue((string)value);
			}
		}



	}


	[FirstByteSQLTypeIndicator(104)]
	public class SQLDatetimeListCreator : SQLListCreator
	{
		private const int UNIT_SIZE = 8;
		private const long NULL_DATE = 119112338422928;
		private static byte[] _nullDate;

		static SQLDatetimeListCreator()
		{
			unchecked
			{
				_nullDate = new byte[8];
				_nullDate[0] = (byte)(NULL_DATE>>56);
				_nullDate[1] = (byte)(NULL_DATE>>48);
				_nullDate[2] = (byte)(NULL_DATE>>40);
				_nullDate[3] = (byte)(NULL_DATE>>32);
				_nullDate[4] = (byte)(NULL_DATE>>24);
				_nullDate[5] = (byte)(NULL_DATE>>16);
				_nullDate[6] = (byte)(NULL_DATE>>8);
				_nullDate[7] = (byte)NULL_DATE;
			}

		}

		public SQLDatetimeListCreator():this(16){}
		public SQLDatetimeListCreator(int size):base(UNIT_SIZE*size){}

	
	
		public void AddNull()
		{
			CheckArrayBounds(UNIT_SIZE);
			_nullDate.CopyTo(m_data, m_ptr);
			m_ptr+=UNIT_SIZE;
		}

		public void AddValue(DateTime value)
		{
			long ts = value.Ticks - 599266080000000000; 
			if(ts<-46388160000010000)
				throw new ArgumentException("Date of " + value.ToString() + " can not be converted to a sql datetime.");

			long ms = ts / 10000;
			CheckArrayBounds(8);
			m_data[m_ptr++] = (byte)(ms>>56);
			m_data[m_ptr++] = (byte)(ms>>48);
			m_data[m_ptr++] = (byte)(ms>>40);
			m_data[m_ptr++] = (byte)(ms>>32);
			m_data[m_ptr++] = (byte)(ms>>24);
			m_data[m_ptr++] = (byte)(ms>>16);
			m_data[m_ptr++] = (byte)(ms>>8);
			m_data[m_ptr++] = (byte)ms;
		}
		public override void AddValue(object value)
		{
			if(IsNull(value))
				AddNull();
			else
			{
				IConvertible ic = value as IConvertible;
				if(ic!=null)
					AddValue(ic.ToDateTime(System.Globalization.CultureInfo.CurrentCulture));
				else
					AddValue((DateTime)value);
			}
		}



	}


	[FirstByteSQLTypeIndicator(105)]
	public class SQLUniqueidentifierListCreator : SQLListCreator
	{
		const int UNIT_SIZE = 16;
		private readonly static byte[] _nullGuidBytes = new byte[]{0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
//		private readonly static byte[] _nullGuidBytes = new byte[]{0x50, 0x61, 0x74, 0x72, 0x69, 0x63, 0x65, 0x20, 0x4C, 0x75, 0x6D, 0x75, 0x6D, 0x62, 0x61, 0x21};
		//		private readonly static Guid _nullGuid;
		
		public SQLUniqueidentifierListCreator():this(16){}
		public SQLUniqueidentifierListCreator(int size):base(UNIT_SIZE*size){}

		//		static SQLUniqueidentifierListCreator()
		//		{
		//			_nullGuid = new Guid(_nullGuidBytes);
		//		}
	
		public void AddNull()
		{
			CheckArrayBounds(UNIT_SIZE);
			_nullGuidBytes.CopyTo(m_data, m_ptr);
			m_ptr+= UNIT_SIZE;
		}

		public void AddValue(Guid value)
		{
			CheckArrayBounds(UNIT_SIZE);
			value.ToByteArray().CopyTo(m_data, m_ptr);
			m_ptr+= UNIT_SIZE;
		}

		public override void AddValue(object value)
		{
			if(IsNull(value))
				AddNull();
			else
				AddValue((Guid)value);
		}
	}


	[FirstByteSQLTypeIndicator(106)]
	public class SQLBigIntListCreator : SQLListCreator
	{
		const int UNIT_SIZE = 8;

		public SQLBigIntListCreator():this(16){}
		public SQLBigIntListCreator(int size):base(UNIT_SIZE*size){}

	
	
		public void AddNull()
		{
			SetNullInt64();
		}

		public void AddValue(long value)
		{
			SetInt64(value);
		}		

		public override void AddValue(object value)
		{
			if(IsNull(value))
				AddNull();
			else
			{
				IConvertible ic = value as IConvertible;
				if(ic!=null)
					AddValue(ic.ToInt64(System.Globalization.CultureInfo.CurrentCulture));
				else
					AddValue((long)value);
			}
		}
	}


	[FirstByteSQLTypeIndicator(107)]
	public class SQLMoneyListCreator : SQLListCreator
	{
		const int UNIT_SIZE = 8;

		public SQLMoneyListCreator():this(16){}
		public SQLMoneyListCreator(int size):base(UNIT_SIZE*size){}


		public void AddNull()
		{
			SetNullInt64();
		}

		public void AddValue(decimal value)
		{
			SetInt64((long)(value*10000m));
		}

		public override void AddValue(object value)
		{
			if(IsNull(value))
				AddNull();
			else
			{
				IConvertible ic = value as IConvertible;
				if(ic!=null)
					AddValue(ic.ToDecimal(System.Globalization.CultureInfo.CurrentCulture));
				else if(value is SqlMoney)
					AddValue(((SqlMoney)value).Value);
				else
					AddValue((decimal)value);
			}
		}
	}


	[FirstByteSQLTypeIndicator(108)]
	public class SQLBitListCreator : SQLListCreator
	{

		private enum Bit 
		{
			False = 0x00,
			True = 0x01,
			Null = 0x02
		}
		private int _currentBiit = 0;
		public SQLBitListCreator():this(4){}
		public SQLBitListCreator(int size):base(((size+1)/4)+1)
		{
			m_ptr++;
		}


		public void AddValue(bool value)
		{
			AddValue((value)?Bit.True:Bit.False);
		}
		public void AddValue(int value)
		{
			if(value==0)
				AddValue(Bit.False);
			else if(value==1)
				AddValue(Bit.True);
			else
				throw new OverflowException(value.ToString() + " is not a valid bit value.");
		}
		public void AddNull()
		{
			AddValue(Bit.Null);
		}

		private void AddValue(Bit bit)
		{
			if(++_currentBiit==4)
			{
				_currentBiit=0;
				m_ptr++;
				CheckArrayBounds(1);
			}
			m_data[m_ptr-1] = (byte)(m_data[m_ptr-1] | ((int)bit)<<(_currentBiit*2)); 
		}

		public override void AddValue(object value)
		{
			if(IsNull(value))
				AddNull();
			else
			{
				IConvertible ic = value as IConvertible;
				if(ic!=null)
					AddValue(ic.ToBoolean(System.Globalization.CultureInfo.CurrentCulture));
				else
					AddValue((bool)value);
			}
		}

		public override string ToString()
		{
			SetStarterOffSet();
			return base.ToString();
		}
		/// <summary>
		/// Creates and returns a byte array list to be passed to a stored procedure as an image. The internal state of the SQLListCreator maintained. If you have no intention of adding more items to the list, after this method call, use GetListAndReset instead.
		/// </summary>
		/// <returns>Byte array to be passed to a stored procedure as an image sql parameter.</returns>
		public override byte[] GetList()
		{
			SetStarterOffSet();
			return base.GetList();
		}
		private void SetStarterOffSet()
		{
			m_data[1] = (byte)(((int)m_data[1]) | _currentBiit);
		}
	}


	[FirstByteSQLTypeIndicator(109)]
	public class SQLRowversionListCreator : SQLListCreator
	{

		const int UNIT_SIZE = 8;
		private readonly static byte[] _nullRowversion = new byte[]{0x4C, 0x75, 0x6D, 0x75, 0x6D, 0x62, 0x61, 0x21};
		
		public SQLRowversionListCreator():this(16){}
		public SQLRowversionListCreator(int size):base(UNIT_SIZE*size){}

	
	
		public void AddNull()
		{
			CheckArrayBounds(UNIT_SIZE);
			_nullRowversion.CopyTo(m_data, m_ptr);
			m_ptr+= UNIT_SIZE;
		}

		public void AddValue(byte[] value)
		{
			if(value==null)
				throw new ArgumentNullException();
			if(value.Length!=UNIT_SIZE)
				throw new ArgumentException();

			if(Array.Equals(value, _nullRowversion))
				throw new BadLuckArgumentException(); 
			
			CheckArrayBounds(UNIT_SIZE);
			value.CopyTo(m_data, m_ptr);
			m_ptr+= UNIT_SIZE;
		}
		public override void AddValue(object value)
		{
			if(IsNull(value))
				AddNull();
			else
				AddValue((byte[])value);
		}



	}

}
